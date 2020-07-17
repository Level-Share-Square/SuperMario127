extends Control

onready var left = $Left
onready var right = $Right

onready var value_text = $Value
var window_scale = 1
const DEFAULT_SIZE = Vector2(768, 432)
const WIDTH_FACTOR = DEFAULT_SIZE.x / DEFAULT_SIZE.y

func _ready():
	window_scale = 5 if OS.window_fullscreen else (OS.window_size.x / DEFAULT_SIZE.x)
	value_text.text = str(window_scale) if window_scale != 5 else "F"
	var _connect = left.connect("pressed", self, "decrease_value")
	var _connect2 = right.connect("pressed", self, "increase_value")

func decrease_value():
	window_scale -= 1
	if window_scale < 1:
		window_scale = 5
	process()

func increase_value():
	window_scale += 1
	if window_scale > 5:
		window_scale = 1
	process()

func process():
	OS.window_fullscreen = window_scale == 5
	
	var window_size : Vector2 = DEFAULT_SIZE * window_scale
	if window_size.x > OS.get_screen_size().x:
		OS.window_size = Vector2(OS.get_screen_size().x, OS.get_screen_size().y * WIDTH_FACTOR)
	else:
		OS.window_size = DEFAULT_SIZE * window_scale
	value_text.text = str(window_scale) if window_scale != 5 else "F"
