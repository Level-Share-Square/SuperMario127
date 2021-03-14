extends Control

onready var button : Button = $Box

var value : bool = false

func _ready():
	value = Singleton.TimeScore.shown
	_update_text()
	var _connect = button.connect("pressed", self, "_update_value")

func _update_value():
	value = !value
	Singleton.TimeScore.shown = value
	_update_text()

func _update_text():
	button.text = "True" if value else "False"
