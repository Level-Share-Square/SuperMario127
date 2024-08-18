tool
extends VBoxContainer

export var setting_section: String
export var setting_key: String
export var default_value: float

export var min_val: float = 0
export var max_val: float = 100

onready var label := $Label
onready var slider = $Panel/HSlider

var value: float = 0

func slider_changed(new_val: float):
	value = new_val
	renamed()
	
	if !Engine.is_editor_hint():
		LocalSettings.change_setting(setting_section, setting_key, value)

func renamed():
	label.text = name.capitalize() + " - " + str(value)


func _ready():
	if !Engine.is_editor_hint():
		value = LocalSettings.load_setting(setting_section, setting_key, default_value)
	
	slider.min_value = min_val
	slider.max_value = max_val
	slider.value = value
	renamed()
