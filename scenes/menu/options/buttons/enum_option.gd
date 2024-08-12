tool
extends VBoxContainer

export (Array, String) var options

onready var label := $Label
onready var button := $Button

var value: int = 0

func pressed():
	value = wrapi(value + 1, 0, options.size())
	button.text = options[value]

func renamed():
	label.text = name.capitalize()


func _ready():
	button.text = options[value]
	renamed()
