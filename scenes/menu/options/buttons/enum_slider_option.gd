tool
extends VBoxContainer

export (Array, String) var options

onready var label := $Label
onready var slider = $Panel/HSlider

var value: int = 0

func slider_changed(new_val: float):
	value = new_val
	renamed()

func renamed():
	label.text = name.capitalize() + " - " + options[value]


func _ready():
	slider.min_value = 0
	slider.max_value = options.size() - 1
	slider.value = value
	renamed()
