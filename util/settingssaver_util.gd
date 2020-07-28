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
	
	if data == null:
		return ControlPresets.presets.Default.duplicate()
	
	if !data.has("controls"):
		var controlPreset
		if data.has("controlPreset"):
			controlPreset = data["controlPreset"]
		elif data.has("controlMode"): # for backwards compatibility
			controlPreset = data["controlMode"]
		else:
			return ControlPresets.presets.Default.duplicate()
		if ControlPresets.presets.has(controlPreset):
			return ControlPresets.presets[controlPreset].duplicate()
	else:
		return data["controls"]
		
static func load_keybindings_into_actions():
	for key in PlayerSettings.keybindings:
		if not InputMap.has_action(key):
			InputMap.add_action(key)
			set_keybindings(key)
				
static func set_keybindings(action):
	var keybindings = PlayerSettings.keybindings
	var binding = keybindings[action] if typeof(keybindings[action]) == TYPE_ARRAY else [keybindings[action]] # Make it an array containing itself for easier processing
	for temp in binding:
		var strmode = temp.keys()[0]
		var mode = int(strmode)
		var ev : InputEvent
		
		if mode == ControlUtil.KEYBOARD: # Have to use str() cuz dic key numbers get saved as strings
			ev = InputEventKey.new()
			ev.scancode = temp[strmode]
		elif mode == ControlUtil.MOUSE:
			ev = InputEventMouseButton.new()
			ev.button_index = temp[strmode]
		elif mode == ControlUtil.JOYPAD_BUTTON:
			ev = InputEventJoypadButton.new()
			ev.device = temp[strmode][0]
			ev.button_index = temp[strmode][1]
		elif mode == ControlUtil.JOYPAD_MOTION:
			ev = InputEventJoypadMotion.new()
			ev.device = temp[strmode][0]
			ev.axis = temp[strmode][1]
			ev.axis_value = temp[strmode][2]
			InputMap.action_set_deadzone(action, 0.5)
		InputMap.action_add_event(action, ev)
	
static func override_keybindings(action):
	InputMap.action_erase_events(action)
	set_keybindings(action)
