class_name SettingsSaver

const PATH = "user://settings.json"

static func load():
	var file = File.new()
	file.open(PATH, File.READ)
	
	var data = parse_json(file.get_as_text())
	
	file.close()
	if typeof(data) == TYPE_DICTIONARY:
		Engine.target_fps = 10 * (data["fpsLock"] + 3)
		PlayerSettings.control_mode = data["controlMode"]
		OS.window_fullscreen = data["windowScale"] == 5
		OS.window_size = Vector2(768, 432) * data["windowScale"]
	
static func save(multiplayerOptions : Node):
	var controlModeLabel : Label = multiplayerOptions.get_node("ControlMode/Value")
	var windowScaleLabel : Label = multiplayerOptions.get_node("WindowScale/Value")
	var fpsLockLabel : Label = multiplayerOptions.get_node("FPSLock/Value")
	
	var controlMode = int(controlModeLabel.text) - 1
	var windowScale = int(windowScaleLabel.text)
	var fpsLock = int(fpsLockLabel.text) / 10 - 3
	
	var data = {
		"controlMode": controlMode,
		"windowScale": windowScale,
		"fpsLock": fpsLock
	}
	
	var file = File.new()
	file.open(PATH, File.WRITE)
	file.store_string(to_json(data))
	file.close()
