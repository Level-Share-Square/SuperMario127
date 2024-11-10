class_name input_event_util


const EMPTY_DICTIONARY = {}

const KEYBOARD = 0
const MOUSE = 1
const JOYPAD_BUTTON = 2
const JOYPAD_MOTION = 3

const DEADZONE = 0.25
const ANY_DEVICE = -1


## convert between inputevent and dictionary, for
## storing input actions into a save file
static func encode_event(dictionary: Dictionary) -> InputEvent:
	var input_event: InputEvent
	match dictionary["input_type"]:
		KEYBOARD:
			input_event = InputEventKey.new()
			input_event.scancode = dictionary.scancode
		
		MOUSE:
			input_event = InputEventMouseButton.new()
			input_event.button_index = dictionary.button_index
		
		JOYPAD_BUTTON:
			input_event = InputEventJoypadButton.new()
			input_event.button_index = dictionary.button_index
		
		JOYPAD_MOTION:
			input_event = InputEventJoypadMotion.new()
			input_event.axis = dictionary.axis
			input_event.axis_value = dictionary.axis_value
	
	input_event.device = ANY_DEVICE
	return input_event


static func decode_event(event: InputEvent) -> Dictionary:
	var dictionary: Dictionary = {}
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		return EMPTY_DICTIONARY
	
	match event.get_class():
		"InputEventKey":
			dictionary["input_type"] = KEYBOARD
			dictionary["scancode"] = event.scancode

		"InputEventMouseButton":
			dictionary["input_type"] = MOUSE
			dictionary["button_index"] = event.button_index
		
		"InputEventJoypadButton":
			dictionary["input_type"] = JOYPAD_BUTTON
			dictionary["button_index"] = event.button_index
		
		"InputEventJoypadMotion":
			if abs(event.axis_value) > DEADZONE:
				dictionary["input_type"] = JOYPAD_MOTION
				dictionary["axis"] = event.axis
				dictionary["axis_value"] = sign(event.axis_value + 0.001)
			else:
				return EMPTY_DICTIONARY
	
	return dictionary


static func is_valid_input_event(event_class: String, is_controller: bool) -> bool:
	match event_class:
		"InputEventKey":
			if not is_controller: return true
		
		"InputEventMouseButton":
			if not is_controller: return true
		
		"InputEventJoypadButton":
			if is_controller: return true
		
		"InputEventJoypadMotion":
			if is_controller: return true
	
	return false


static func is_controller_input(event_dict: Dictionary) -> bool:
	if not "input_type" in event_dict: return false
	return event_dict.input_type == JOYPAD_BUTTON or event_dict.input_type == JOYPAD_MOTION
	

## For getting human-readable names from button_index variables.
const UNKNOWN = "Unknown"
const MOUSE_BUTTONS: Array = [
	UNKNOWN,
	"Left Click",
	"Right Click",
	"Middle Click",
	"Wheel Up",
	"Wheel Down",
	"Wheel Left",
	"Wheel Right",
	"Click 4",
	"Click 5"
]
const JOY_BUTTONS: Array = [
	"A",
	"B",
	"X",
	"Y",
	"LB",
	"RB",
	"LT",
	"RT",
	"LS",
	"RS",
	"Select",
	"Start",
	"Up",
	"Down",
	"Left",
	"Right",
	"Logo",
	"Misc",
	"Paddle 1",
	"Paddle 2",
	"Paddle 3",
	"Paddle 4",
	"Touchpad"
]


static func get_singular_human_name(event: Dictionary) -> String:
	var string: String = ""
	match(event.input_type):
		KEYBOARD:
			string += OS.get_scancode_string(event.scancode)
		
		MOUSE:
			if event.button_index < MOUSE_BUTTONS.size():
				string += MOUSE_BUTTONS[event.button_index]
			else:
				string += UNKNOWN
		
		JOYPAD_BUTTON:
			if event.button_index < JOY_BUTTONS.size():
				string += JOY_BUTTONS[event.button_index]
			else:
				string += UNKNOWN
		
		JOYPAD_MOTION:
			var suffix = "+" if event.axis_value > 0 else "-"
			string += "Axis " + str(event.axis) + suffix
	
	return string


static func get_human_name(event_array: Array) -> String:
	var string: String = ""
	for event in event_array:
		if string != "": string += ", "
		string += get_singular_human_name(event)
		
	return string
