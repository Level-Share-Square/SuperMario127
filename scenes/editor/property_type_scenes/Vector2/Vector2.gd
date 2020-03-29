extends Control

export var x_edit : NodePath
export var y_edit : NodePath

onready var x_edit_node : LineEdit = get_node(x_edit)
onready var y_edit_node : LineEdit = get_node(y_edit)

func _ready():
	x_edit_node.connect("focus_exited", self, "update_value")
	y_edit_node.connect("focus_exited", self, "update_value")

func set_value(value: Vector2):
	x_edit_node.text = str(value.x)
	y_edit_node.text = str(value.y)

func get_value() -> Vector2:
	return Vector2(float(x_edit_node.text), float(y_edit_node.text))

func update_value():
	get_node("../").update_value(get_value())
