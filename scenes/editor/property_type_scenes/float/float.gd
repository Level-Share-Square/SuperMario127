extends Control

export var line_edit : NodePath

onready var line_edit_node : LineEdit = get_node(line_edit)

func _ready():
	line_edit_node.connect("focus_exited", self, "update_value")

func set_value(value: float):
	line_edit_node.text = str(value)

func get_value() -> float:
	return float(line_edit_node.text)

func update_value():
	get_node("../").update_value(get_value())
