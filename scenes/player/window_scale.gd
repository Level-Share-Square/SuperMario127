extends Control

onready var left : TextureButton = $Left
onready var right : TextureButton = $Right
onready var value_text : Label = $Value

var window_scale := 1
var previous_scale : int = window_scale

const FULLSCREEN_SCALE_VALUE := 3
const PATH : String = "user://settings.json"

const DEFAULT_SIZE = Vector2(768, 432)

func _ready() -> void:
	var file : File = File.new()
	# warning-ignore: return_value_discarded
	file.open(PATH, File.READ)
	
	var data = parse_json(file.get_as_text())
	
	file.close()
	
	if OS.window_fullscreen:
		window_scale = FULLSCREEN_SCALE_VALUE 
	else: 
		window_scale = int(window_scale)
		if not (data == null or data["windowScale"] == null):
			window_scale = data["windowScale"]
	
	value_text.text = str(window_scale) if !OS.window_fullscreen else "F"
	# warning-ignore: return_value_discarded
	left.connect("pressed", self, "decrease_value")
	# warning-ignore: return_value_discarded
	right.connect("pressed", self, "increase_value")

func decrease_value() -> void:
	var new_window_scale : int = window_scale - 1
	if new_window_scale < 1:
		new_window_scale = FULLSCREEN_SCALE_VALUE
	if OS.window_fullscreen:
		new_window_scale = 1
	update_window_scale(new_window_scale)

func increase_value() -> void:
	var new_window_scale : int = window_scale + 1
	if new_window_scale > FULLSCREEN_SCALE_VALUE or OS.window_fullscreen:
		new_window_scale = 1
	update_window_scale(new_window_scale)

func _input(_event) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		if !OS.window_fullscreen:
			update_window_scale(FULLSCREEN_SCALE_VALUE)
		elif previous_scale != FULLSCREEN_SCALE_VALUE: #this extra bit is so if you toggle fullscreen on the same instance you'll go back to the same scale
			update_window_scale(previous_scale)
		else:
			update_window_scale(1)
		SettingsSaver.save() #has to be called manually here since normally settings are saved via the settings menu

func update_window_scale(new_window_scale) -> void:
	ScreenSizeUtil.set_screen_size(new_window_scale)
	value_text.text = str(new_window_scale) if !OS.window_fullscreen else "F"
	previous_scale = window_scale
	window_scale = new_window_scale
	SettingsSaver.save()
