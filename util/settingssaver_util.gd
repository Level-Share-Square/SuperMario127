class_name SettingsSaver

const PATH = "user://settings.json"
const DEFAULT_SIZE = Vector2(768, 432)
const WIDTH_FACTOR = DEFAULT_SIZE.x / DEFAULT_SIZE.y

static func load():
	var file = File.new()
	file.open(PATH, File.READ)
	
	var data = parse_json(file.get_as_text())
	
	file.close()
	if typeof(data) == TYPE_DICTIONARY:
		Engine.target_fps = 10 * (data["fpsLock"] + 3)
		PlayerSettings.control_mode = data["controlMode"]
		set_screen_size(data)

static func set_screen_size(data):
	OS.window_fullscreen = data["windowScale"] == 5
	
	var window_size : Vector2 = DEFAULT_SIZE * data["windowScale"]
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

static func save(multiplayerOptions : Node):
	var controlModeLabel : Label = multiplayerOptions.get_node("ControlMode/Value")
	var windowScaleLabel : Label = multiplayerOptions.get_node("WindowScale/Value")
	var fpsLockLabel : Label = multiplayerOptions.get_node("FPSLock/Value")
	
	var controlMode = int(controlModeLabel.text) - 1
	var windowScale = int(windowScaleLabel.text)
	var fpsLock = int(fpsLockLabel.text) / 10 - 3
	
	if windowScale == 0:
		windowScale = 5
	
	var data = {
		"controlMode": controlMode,
		"windowScale": windowScale,
		"fpsLock": fpsLock
	}
	
	var file = File.new()
	file.open(PATH, File.WRITE)
	file.store_string(to_json(data))
	file.close()
