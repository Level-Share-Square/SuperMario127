extends Control

export var line_edit_path : NodePath

onready var line_edit : LineEdit = get_node(line_edit_path)

func set_value(value: float):
	line_edit.text = str(value)

func get_value() -> float:
	return float(line_edit.text)

func update_value():
	get_parent().update_value(get_value())
