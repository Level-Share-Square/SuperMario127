extends Popup

onready var ok_button = $HBoxContainer/OkButton
onready var cancel_button = $HBoxContainer/CancelButton

signal confirmed

func _ready():
	var _connect
	ok_button.connect("pressed", self, "on_ok_pressed")
	cancel_button.connect("pressed", self, "on_cancel_pressed")

func on_ok_pressed():
	emit_signal("confirmed")

func on_cancel_pressed():
	visible = false
