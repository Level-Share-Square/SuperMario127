tool
extends VBoxContainer

export var setting_section: String
export var setting_key: String
export var default_value: int

export (Array, String) var options

onready var label := $Label
onready var slider = $Panel/HSlider

var value: int = 0

func slider_changed(new_val: float):
	value = new_val
	renamed()
	
	LocalSettings.change_setting(setting_section, setting_key, value)

func renamed():
	label.text = name.capitalize() + " - " + options[value]


func _ready():
	value = LocalSettings.load_setting(setting_section, setting_key, default_value)
	
	slider.min_value = 0
	slider.max_value = options.size() - 1
	slider.value = value
	renamed()
