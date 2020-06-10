extends Control

export var h_edit : NodePath
export var s_edit : NodePath
export var v_edit : NodePath

onready var h_edit_node : LineEdit = get_node(h_edit)
onready var s_edit_node : LineEdit = get_node(s_edit)
onready var v_edit_node : LineEdit = get_node(v_edit)

func _ready():
	var _connect = h_edit_node.connect("focus_exited", self, "update_value")
	var _connect2 = s_edit_node.connect("focus_exited", self, "update_value")
	var _connect3 = v_edit_node.connect("focus_exited", self, "update_value")

func set_value(value: Color):
	h_edit_node.text = str(int(value.h * 255))
	s_edit_node.text = str(int(value.s * 255))
	v_edit_node.text = str(int(value.v * 255))

func get_value() -> Color:
	return Color().from_hsv(float(h_edit_node.text) / 255, float(s_edit_node.text) / 255, float(v_edit_node.text) / 255)

func update_value():
	get_node("../").update_value(get_value())
