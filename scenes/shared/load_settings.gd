extends Node

func _ready():
	SettingsSaver.load()
	SettingsSaver.load_keybindings_into_actions()
