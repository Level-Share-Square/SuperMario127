extends Control

export var h_edit : NodePath
export var s_edit : NodePath
export var v_edit : NodePath
export var a_edit : NodePath

onready var h_edit_node : LineEdit = get_node(h_edit)
onready var s_edit_node : LineEdit = get_node(s_edit)
onready var v_edit_node : LineEdit = get_node(v_edit)
onready var a_edit_node : LineEdit = get_node(a_edit)

func _ready():
	var edit_nodes = [h_edit_node, s_edit_node, v_edit_node, a_edit_node]
	
	for edit_node in edit_nodes:
		edit_node.connect("focus_exited", self, "update_value", [edit_node])

func set_value(value: Color):
	h_edit_node.text = str(int(value.r * 255))
	s_edit_node.text = str(int(value.g * 255))
	v_edit_node.text = str(int(value.b * 255))
	a_edit_node.text = str(int(value.a * 255))

func get_value() -> Color:
	return Color(float(h_edit_node.text) / 255, float(s_edit_node.text) / 255, float(v_edit_node.text) / 255, float(a_edit_node.text) / 255)

func update_value(edit_node : LineEdit):
	if !edit_node.check():
		return
	get_node("../").update_value(get_value())
