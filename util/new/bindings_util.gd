class_name bindings_util

const EMPTY_DICTIONARY = {}

const KEYBOARD = 0
const MOUSE = 1
const JOYPAD_BUTTON = 2
const JOYPAD_MOTION = 3

const DEADZONE = 0.25

const UNKNOWN = "Unknown"

static func decode_event(event: InputEvent) -> Dictionary:
	var dictionary: Dictionary = {}
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		return EMPTY_DICTIONARY
	
	dictionary["device"] = event.device
	match event.get_class():
		"InputEventKey":
			dictionary["input_type"] = KEYBOARD
			print("Scancode: " + str(event.scancode))

		"InputEventMouseButton":
			dictionary["input_type"] = MOUSE
			print("Button index: " + str(event.button_index))
		
		"InputEventJoypadButton":
			dictionary["input_type"] = JOYPAD_BUTTON
			print("Button index: " + str(event.button_index))
		
		"InputEventJoypadMotion":
			if abs(event.axis_value) > DEADZONE:
				dictionary["input_type"] = JOYPAD_MOTION
				print("Axis: " + str(event.axis))
				print("Axis direction: " + str(sign(event.axis_value)))
			else:
				return EMPTY_DICTIONARY
	
	print("Device: " + str(dictionary.device))
	return dictionary
