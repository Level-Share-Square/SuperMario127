tool
extends VBoxContainer

const ON_TEXT: String = "On"
const OFF_TEXT: String = "Off"

export var setting_section: String
export var setting_key: String
export var default_value: bool

onready var label := $Label
onready var button := $Button

var value: bool = false

func pressed():
	value = !value
	button.text = ON_TEXT if value else OFF_TEXT
	
	LocalSettings.change_setting(setting_section, setting_key, value)

func renamed():
	label.text = name.capitalize()


func _ready():
	value = LocalSettings.load_setting(setting_section, setting_key, default_value)
	button.text = ON_TEXT if value else OFF_TEXT
	
	renamed()
