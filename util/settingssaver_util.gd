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
		if data.has("richpresence"):
			Singleton2.rp = data["richpresence"]
		if data.has("darkmode"):
			Singleton2.dark_mode = data["darkmode"]
		if data.has("crashdetect"):
			Singleton2.crash = data["crashdetect"]
		if data.has("showghost"):
			Singleton2.ghost_enabled = data["showghost"]
		if data.has("showTimer"):
			Singleton.TimeScore.shown = data["showTimer"]
		#if data.has("volume"):
			#Singleton.Music.set_global_volume(data["volume"])
		if data.has("legacyWingCap"):
			# imo this is cleaner than putting it in presets atm
			Singleton.PlayerSettings.legacy_wing_cap = data["legacyWingCap"]
		if data.has("gameVersion"):
			if data["gameVersion"] != Singleton.PlayerSettings.game_version:
				Singleton.SavedLevels.wipe_template_levels()
				if data.has("windowScale"):
					data["windowScale"] = 1
				save()
		else:
			Singleton.SavedLevels.wipe_template_levels()
			save()
	
		if data.has("numberOfTiles"):
			Singleton.EditorSavedSettings.data_tiles = data["numberOfTiles"]
			
		if data.has("savedPalettes"):
			Singleton.EditorSavedSettings.tileset_palettes = data["savedPalettes"]
	
		yield(Singleton.EditorSavedSettings.get_tree().create_timer(1), "timeout")
		
		if data.has("windowScale"):
			ScreenSizeUtil.set_screen_size(data["windowScale"])

static func save():
	var windowScale = Singleton.EditorSavedSettings.stored_window_scale
	var fpsLock = (Engine.target_fps / 10.0) - 3
	var showTimer = Singleton.TimeScore.shown
	var richpresence = Singleton2.rp
	var darkmode = Singleton2.dark_mode
	var crashdetect = Singleton2.crash
	var showghost = Singleton2.ghost_enabled
	var legacyCap = Singleton.PlayerSettings.legacy_wing_cap
	
	var data = {
		"windowScale": windowScale,
		"fpsLock": fpsLock,
		"showTimer": showTimer,
		"richpresence": richpresence,
		"darkmode": darkmode,
		"crashdetect": crashdetect,
		"showghost": showghost,
		"controls": Singleton.PlayerSettings.keybindings,
		"volume": Singleton.Music.global_volume,
		"legacyWingCap": legacyCap,
		"gameVersion": Singleton.PlayerSettings.game_version,
		"numberOfTiles": Singleton.EditorSavedSettings.data_tiles,
		"savedPalettes": Singleton.EditorSavedSettings.tileset_palettes
	}
	
	var file = File.new()
	file.open(PATH, File.WRITE)
	file.store_string(to_json(data))
	file.close()

static func save_volume():
	var data = get_data_or_null()
	if data == null:
		# Default config
		data = {
			"windowScale": 1,
			"fpsLock": 3,
			"showTimer": false,
			"richpresence": true,
			"darkmode": true,
			"crashdetect": false,
			"showghost": true,
			"controls": Singleton.PlayerSettings.keybindings,
			"volume": Singleton.Music.global_volume,
			"legacyWingCap": Singleton.PlayerSettings.legacy_wing_cap,
			"gameVersion": Singleton.PlayerSettings.game_version,
			"numberOfTiles": Singleton.EditorSavedSettings.data_tiles,
			"savedPalettes": Singleton.EditorSavedSettings.tileset_palettes
		}
	
	data["volume"] = Singleton.Music.global_volume
	
	var file = File.new()
	file.open(PATH, File.WRITE)
	file.store_string(to_json(data))
	file.close()

static func get_keybindings() -> Array:
	var data = get_data_or_null()
	convert_old_controls(data)
	
	if data == null || !data.has("controls"):
		return [
			ControlPresets.presets.Default.duplicate(true),
			ControlPresets.presets.WASD.duplicate(true)
		]
	else:
		return data["controls"]
		
static func load_keybindings_into_actions():
	var _actualName
	for i in range(0, Singleton.PlayerSettings.keybindings.size()):
		for key in Singleton.PlayerSettings.keybindings[i]:
			var input_name = key + str(i)
			if not InputMap.has_action(key + input_name):
				InputMap.add_action(input_name)
				set_keybindings(key, i)
				
static func set_keybindings(action : String, player_id : int):
	var binding = Singleton.PlayerSettings.keybindings[player_id][action]
	var input_name = action + str(player_id)
	for temp in binding:
		var mode = temp[0]
		var ev : InputEvent
		
		if mode == ControlUtil.KEYBOARD:
			ev = InputEventKey.new()
			ev.scancode = temp[1]
		elif mode == ControlUtil.MOUSE:
			ev = InputEventMouseButton.new()
			ev.button_index = temp[1]
		elif mode == ControlUtil.JOYPAD_BUTTON:
			ev = InputEventJoypadButton.new()
			ev.device = temp[1]
			ev.button_index = temp[2]
		elif mode == ControlUtil.JOYPAD_MOTION:
			ev = InputEventJoypadMotion.new()
			ev.device = temp[1]
			ev.axis = temp[2]
			ev.axis_value = temp[3]
			InputMap.action_set_deadzone(input_name, 0.5)
		InputMap.action_add_event(input_name, ev)
	
static func override_keybindings(action : String, player_id : int):
	InputMap.action_erase_events(action + str(player_id))
	set_keybindings(action, player_id)



# Converts 0.6.0 controls to 0.6.1 (adds Move Up/Move Down keys)
# Assumes data is not null
static func convert_controls_060_to_061(data):
	if data.has("controls"):
		# for each player
		for i in range(data["controls"].size()):
			var controls = data["controls"][i]
			if !controls.has("up"):
				# Set default values
				controls["up"] = [[ControlUtil.KEYBOARD, KEY_UP]]
				controls["down"] = [[ControlUtil.KEYBOARD, KEY_DOWN]]
				
				if controls["left"][0][0] == ControlUtil.KEYBOARD:
					# Adapt for WASD
					if controls["left"][0][1] == KEY_A:
						controls["up"] = [[ControlUtil.KEYBOARD, KEY_W]]
						controls["down"] = [[ControlUtil.KEYBOARD, KEY_S]]
				elif controls["left"][0][0] == ControlUtil.JOYPAD_BUTTON:
					# Adapt for controller d-pad
					controls["up"] = [[ControlUtil.JOYPAD_BUTTON, JOY_DPAD_UP]]
					controls["down"] = [[ControlUtil.JOYPAD_BUTTON, JOY_DPAD_DOWN]]

static func convert_old_controls(data):
	if data == null: return
	
	convert_controls_060_to_061(data)
