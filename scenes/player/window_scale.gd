extends Control

onready var left = $Left
onready var right = $Right

onready var value_text = $Value
var window_scale = 1
const FULLSCREEN_SCALE_VALUE = 5
const PATH = "user://settings.json"

func _ready():
	var file = File.new()
	file.open(PATH, File.READ)
	
	var data = parse_json(file.get_as_text())
	
	file.close()
	
	window_scale = FULLSCREEN_SCALE_VALUE if OS.window_fullscreen else (OS.window_size.x / ScreenSizeUtil.DEFAULT_SIZE.x) if data["windowScale"] == null else data["windowScale"]
	value_text.text = str(window_scale) if window_scale != FULLSCREEN_SCALE_VALUE else "F"
	var _connect = left.connect("pressed", self, "decrease_value")
	var _connect2 = right.connect("pressed", self, "increase_value")

func decrease_value():
	window_scale -= 1
	if window_scale < 1:
		window_scale = FULLSCREEN_SCALE_VALUE
	ScreenSizeUtil.set_screen_size(window_scale)
	update_value_text(window_scale)

func increase_value():
	window_scale += 1
	if window_scale > FULLSCREEN_SCALE_VALUE:
		window_scale = 1
	ScreenSizeUtil.set_screen_size(window_scale)
	update_value_text(window_scale)

func _input(_event):
	if Input.is_action_just_pressed("fullscreen"):
		window_scale = FULLSCREEN_SCALE_VALUE if !OS.window_fullscreen else 1
		ScreenSizeUtil.set_screen_size(window_scale)
		update_value_text(window_scale)
		
func update_value_text(new_window_scale):
	value_text.text = str(new_window_scale) if new_window_scale != FULLSCREEN_SCALE_VALUE else "F"