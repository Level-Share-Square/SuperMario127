extends Control

onready var left = $Left
onready var right = $Right

onready var value_text = $Value
var window_scale = 1
const PATH = "user://settings.json"
const DEFAULT_SIZE = Vector2(768, 432)
const WIDTH_FACTOR = DEFAULT_SIZE.x / DEFAULT_SIZE.y

func _ready():
	var file = File.new()
	file.open(PATH, File.READ)
	
	var data = parse_json(file.get_as_text())
	
	file.close()
	
	window_scale = 5 if OS.window_fullscreen else (OS.window_size.x / DEFAULT_SIZE.x) if data["windowScale"] == null else data["windowScale"]
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
	print(window_size)
	var max_size = Vector2(OS.get_screen_size().x, OS.get_screen_size().y)
	print(max_size)
	var modified = false
	if window_size.x > max_size.x:
		OS.window_size = Vector2(max_size.x, max_size.x / WIDTH_FACTOR)
		modified = true
	if window_size.y > max_size.y:
		OS.window_size = Vector2(max_size.y * WIDTH_FACTOR, max_size.y)
		modified = true
	
	if !modified:
		OS.window_size = window_size
	
	value_text.text = str(window_scale) if window_scale != 5 else "F"
