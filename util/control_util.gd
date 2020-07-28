class_name ControlUtil

const KEYBOARD = 0
const MOUSE = 1
const JOYPAD_BUTTON = 2
const JOYPAD_MOTION = 3

const UNKNOWN = "Unknown"

static func get_formatted_string(action) -> String:
	var keybinding : Dictionary = PlayerSettings.keybindings[action]
	var mode = keybinding.keys()[0]
	
	match int(mode):
		KEYBOARD:
			return OS.get_scancode_string(keybinding[mode])
		MOUSE:
			return convert_button_index_to_string(keybinding[mode])
		JOYPAD_BUTTON:
			return "JB" + str(keybinding[mode][1])
		JOYPAD_MOTION:
			return "Axis " + str(keybinding[mode][1]) + ("+" if keybinding[mode][2] == 1 else "-")
	
	return UNKNOWN

static func convert_button_index_to_string(button_index):
	match button_index:
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
	
	return UNKNOWN
