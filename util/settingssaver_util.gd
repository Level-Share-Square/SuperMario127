class_name SettingsSaver

const PATH = "user://settings.json"

static func get_data_or_null():
	var file = File.new()
	file.open(PATH, File.READ)
	
	var data = parse_json(file.get_as_text())
	
	file.close()
	if typeof(data) == TYPE_DICTIONARY:
		return data
	else:
		return null

static func load():
	var data = get_data_or_null()
	if data != null:
		Engine.target_fps = 10 * (data["fpsLock"] + 3)
		ScreenSizeUtil.set_screen_size(data["windowScale"])

static func save(multiplayerOptions : Node):
	var windowScaleLabel : Label = multiplayerOptions.get_node("WindowScale/Value")
	var fpsLockLabel : Label = multiplayerOptions.get_node("FPSLock/Value")
	
	var windowScale = int(windowScaleLabel.text)
	var fpsLock = int(fpsLockLabel.text) / 10.0 - 3
	
	if windowScale == 0:
		windowScale = 5
	
	var data = {
		"windowScale": windowScale,
		"fpsLock": fpsLock
	}
	
	var savedPreset : String = ""
	for preset_name in ControlPresets.presets:
		if savedPreset.empty() && PlayerSettings.keybindings.hash() == ControlPresets.presets[preset_name].hash():
			savedPreset = preset_name
	
	if savedPreset.empty():
		data["controls"] = PlayerSettings.keybindings
	else:
		data["controlPreset"] = savedPreset
	
	var file = File.new()
	file.open(PATH, File.WRITE)
	file.store_string(to_json(data))
	file.close()

static func get_keybindings() -> Dictionary:
	var data = get_data_or_null()
	if data == null || !data.has("controls"):
		if data.has("controlPreset"):
			var controlPreset = data["controlPreset"]
			if ControlPresets.presets.has(controlPreset):
				return ControlPresets.presets[controlPreset]
		return ControlPresets.presets["Default"]
	else:
		return data["controls"]
