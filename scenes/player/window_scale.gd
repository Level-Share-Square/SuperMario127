extends Control

onready var left = $Left
onready var right = $Right

onready var value_text = $Value
var window_scale = 1
var previous_scale = window_scale
const FULLSCREEN_SCALE_VALUE = 5
const PATH = "user://settings.json"

func _ready():
	var file = File.new()
	file.open(PATH, File.READ)
	
	var data = parse_json(file.get_as_text())
	
	file.close()
	
	# warning-ignore: incompatible_ternary
	window_scale = FULLSCREEN_SCALE_VALUE if OS.window_fullscreen else (OS.window_size.x / ScreenSizeUtil.DEFAULT_SIZE.x) if data == null || data["windowScale"] == null else data["windowScale"]
	value_text.text = str(window_scale) if window_scale != FULLSCREEN_SCALE_VALUE else "F"
	var _connect = left.connect("pressed", self, "decrease_value")
	var _connect2 = right.connect("pressed", self, "increase_value")

func decrease_value():
	var new_window_scale = window_scale - 1
	if new_window_scale < 1:
		new_window_scale = FULLSCREEN_SCALE_VALUE
	update_window_scale(new_window_scale)

func increase_value():
	var new_window_scale = window_scale + 1
	if new_window_scale > FULLSCREEN_SCALE_VALUE:
		new_window_scale = 1
	update_window_scale(new_window_scale)

func _input(_event):
	if Input.is_action_just_pressed("fullscreen"):
		if !OS.window_fullscreen:
			update_window_scale(FULLSCREEN_SCALE_VALUE)
		elif previous_scale != FULLSCREEN_SCALE_VALUE: #this extra bit is so if you toggle fullscreen on the same instance you'll go back to the same scale
			update_window_scale(previous_scale)
		else:
			update_window_scale(1)
		SettingsSaver.save(get_parent()) #has to be called manually here since normally settings are saved via the settings menu

func update_window_scale(new_window_scale):
	ScreenSizeUtil.set_screen_size(new_window_scale)
	value_text.text = str(new_window_scale) if new_window_scale != FULLSCREEN_SCALE_VALUE else "F"
	previous_scale = window_scale
	window_scale = new_window_scale
