tool
extends VBoxContainer

export var setting_section: String
export var setting_key: String
export var default_value: int

export (Array, String) var options

onready var label := $Label
onready var button := $Button

var value: int = 0

func pressed():
	value = wrapi(value + 1, 0, options.size())
	button.text = options[value]
	
	if !Engine.is_editor_hint():
		LocalSettings.change_setting(setting_section, setting_key, value)

func renamed():
	label.text = name.capitalize()


func _ready():
	if !Engine.is_editor_hint():
		value = LocalSettings.load_setting(setting_section, setting_key, default_value)
	
	button.text = options[value]
	renamed()
