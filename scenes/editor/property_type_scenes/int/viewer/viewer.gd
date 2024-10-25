extends Control

export var label_path : NodePath

onready var label : Label = get_node(label_path)

func set_value(value: int):
	label.text = str(value)

func get_value() -> int:
	return int(label.text)

func update_value():
	get_parent().update_value(get_value())
