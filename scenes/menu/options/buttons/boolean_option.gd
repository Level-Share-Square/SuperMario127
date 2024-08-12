tool
extends VBoxContainer

export var on_text: String = "On"
export var off_text: String = "Off"

onready var label := $Label
onready var button := $Button

var value: bool = false

func pressed():
	value = !value
	button.text = on_text if value else off_text

func renamed():
	label.text = name.capitalize()


func _ready():
	renamed()
