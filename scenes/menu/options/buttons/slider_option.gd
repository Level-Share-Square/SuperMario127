tool
extends VBoxContainer

export var min_val: float = 0
export var max_val: float = 100

onready var label := $Label
onready var slider = $Panel/HSlider

var value: float = 0

func slider_changed(new_val: float):
	value = new_val
	renamed()

func renamed():
	label.text = name.capitalize() + " - " + str(value)


func _ready():
	slider.min_value = min_val
	slider.max_value = max_val
	slider.value = value
	renamed()
