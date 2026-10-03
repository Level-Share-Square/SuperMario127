extends Control

onready var button : Button = $Box

var value : bool = false

func _ready():
	value = LocalSettings.load_setting("General", "dark_mode", false)
	_update_text()
	var _connect = button.connect("pressed", self, "_update_value")

func _update_value():
	value = !value
	LocalSettings.change_setting("General", "dark_mode", value)
	_update_text()

func _update_text():
	button.text = "True" if value else "False"
