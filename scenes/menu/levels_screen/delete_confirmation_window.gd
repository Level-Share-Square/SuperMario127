extends Popup

onready var ok_button = $HBoxContainer/OkButton
onready var cancel_button = $HBoxContainer/CancelButton

signal confirmed

var index_to_send

func _ready():
	var _connect
	ok_button.connect("pressed", self, "on_ok_pressed")
	cancel_button.connect("pressed", self, "on_cancel_pressed")

func on_ok_pressed():
	emit_signal("confirmed", index_to_send)
	visible = false
	get_parent().visible = false

func on_cancel_pressed():
	visible = false
	get_parent().visible = false

func set_level_name(name):
	$Label.text = 'Are you sure you want to delete the level\n"' + name + '"?'
