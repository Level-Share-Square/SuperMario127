class_name ControlUtil

const KEYBOARD = 0
const MOUSE = 1
const JOYPAD_BUTTON = 2
const JOYPAD_MOTION = 3

const UNKNOWN = "Unknown"

static func get_formatted_string_by_index(action : String, player_id : int, index : int) -> String:
	var keybinding = Singleton.PlayerSettings.keybindings[player_id][action]
	var mode = keybinding[index][0]

	match int(mode):
		KEYBOARD:
			return OS.get_scancode_string(keybinding[index][1])
		MOUSE:
			return convert_button_index_to_string(keybinding[index][1])
		JOYPAD_BUTTON:
			return "JB" + str(keybinding[index][2])
		JOYPAD_MOTION:
			return "Axis " + str(keybinding[index][2]) + ("+" if keybinding[index][3] == 1 else "-")
	
	return UNKNOWN
	
static func get_formatted_string(action : String, player_id : int) -> String:
	return get_formatted_string_by_index(action, player_id, 0)

static func convert_button_index_to_string(button_index):
	match int(button_index):
		BUTTON_LEFT:
			return "LMB"
		BUTTON_RIGHT:
			return "RMB"
		BUTTON_MIDDLE:
			return "MMB"
		BUTTON_WHEEL_UP:
			return "WUP"
		BUTTON_WHEEL_DOWN:
			return "WDOWN"
		BUTTON_WHEEL_LEFT:
			return "WLEFT"
		BUTTON_WHEEL_RIGHT:
			return "WRIGHT"
		BUTTON_XBUTTON1:
			return "XB1"
		BUTTON_XBUTTON2:
			return "XB2"
		_:
			return UNKNOWN
			
static func get_device_info(id, player_id, index):
	var result = "Device: "
	var keybindings = Singleton.PlayerSettings.keybindings[player_id][id][index]
	var mode : int = keybindings[0]
	
	match(mode):
		KEYBOARD:
			return result + "Keyboard"
		MOUSE:
			return result + "Mouse"
		_:
			return result + str(keybindings[1]) + "-Joystick"

static func binding_alias_already_exists(id : String, player_id : int, index : int, data : Array):
	var keybindings = Singleton.PlayerSettings.keybindings[player_id][id]
	for i in range(0, keybindings.size()):
		if index == i:
			continue
		
		if keybindings[i] == null:
			return false
			
		if _arrays_equal(keybindings[i], data):
			Singleton.NotificationHandler.error("Binding error", "The binding you've set already exists for this action!")
			return true
	
	return false

static func _arrays_equal(a, b):
	if a.size() != b.size():
		return false
	for i in range(a.size()):
		var val_a = a[i]
		var val_b = b[i]
		if val_a != val_b:
			return false
	return true
