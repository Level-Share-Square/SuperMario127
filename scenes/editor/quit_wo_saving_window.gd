extends Popup

onready var ok_button = $HBoxContainer/OkButton
onready var cancel_button = $HBoxContainer/CancelButton

var open_window: EditorWindow setget set_open_window

signal confirmed

func set_open_window(window: EditorWindow)-> void:
	
	open_window = window

func _ready():
	var _connect
	ok_button.connect("pressed", self, "on_ok_pressed")
	cancel_button.connect("pressed", self, "on_cancel_pressed")

func on_ok_pressed():
	emit_signal("confirmed")

func on_cancel_pressed():
	visible = false
	
	if (open_window != null):
		open_window.open()
