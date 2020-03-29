extends Control

export var button : NodePath

onready var button_node : Button = get_node(button)

var value = true

func _ready():
	button_node.connect("pressed", self, "update_value")

func set_value(value: bool):
	self.value = value
	button_node.text = "True" if value else "False"

func get_value() -> bool:
	return value

func update_value():
	set_value(!value)
	get_node("../").update_value(get_value())
