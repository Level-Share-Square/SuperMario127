extends Control

onready var button : Button = $Box
onready var folder = $Folder

var value : bool = false

func _ready():
	value = Singleton2.ghost_enabled
	_update_text()
	var _connect = button.connect("pressed", self, "_update_value")
	_connect = folder.connect("button_down", self, "open_folder")

func _update_value():
	value = !value
	Singleton2.ghost_enabled = value
	_update_text()

func open_folder():
	OS.shell_open(ProjectSettings.globalize_path("user://replays"))

func _update_text():
	button.text = "True" if value else "False"
