extends Control

onready var left = $Left
onready var right = $Right

onready var value_text = $Value
var window_scale = 1

func _ready():
	window_scale = OS.window_size.x / 768
	value_text.text = str(PlayerSettings.control_mode + 1)
	var _connect = left.connect("pressed", self, "decrease_value")
	var _connect2 = right.connect("pressed", self, "increase_value")

func decrease_value():
	window_scale -= 1
	if window_scale < 1:
		window_scale = 5
	OS.window_fullscreen = window_scale == 5
	OS.window_size = Vector2(768, 432) * window_scale
	value_text.text = str(window_scale) if window_scale != 5 else "F"

func increase_value():
	window_scale += 1
	if window_scale > 5:
		window_scale = 1
	OS.window_fullscreen = window_scale == 5
	OS.window_size = Vector2(768, 432) * window_scale
	value_text.text = str(window_scale) if window_scale != 5 else "F"
