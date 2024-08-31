class_name bindings_util

const EMPTY_DICTIONARY = {}

const KEYBOARD = 0
const MOUSE = 1
const JOYPAD_BUTTON = 2
const JOYPAD_MOTION = 3

const DEADZONE = 0.25
const UNKNOWN = "Unknown"

## For getting human-readable names from button_index variables.
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
	
	input_event.device = -1
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


## for displaying bindings in text
static func get_singular_human_name(action: Dictionary) -> String:
	var string: String = ""
	match(action.input_type):
		KEYBOARD:
			string += OS.get_scancode_string(action.scancode)
		
		MOUSE:
			if action.button_index < MOUSE_BUTTONS.size():
				string += MOUSE_BUTTONS[action.button_index]
			else:
				string += UNKNOWN
		
		JOYPAD_BUTTON:
			if action.button_index < JOY_BUTTONS.size():
				string += JOY_BUTTONS[action.button_index]
			else:
				string += UNKNOWN
		
		JOYPAD_MOTION:
			var suffix = "+" if action.axis_value > 0 else "-"
			string += "Axis " + str(action.axis) + suffix
	
	return string

static func get_binding_human_name(action_array: Array) -> String:
	var string: String = ""
	for action in action_array:
		if string != "": string += ", "
		string += get_singular_human_name(action)
		
	return string


## functions that edit the actual control bindings
static func add_binding(action: String, player_id: int, event_dict: Dictionary):
	var input_name: String = action
	if player_id > -1:
		input_name += str(player_id)
	
	if not InputMap.has_action(input_name):
		InputMap.add_action(input_name, DEADZONE)
	
	if event_dict == EMPTY_DICTIONARY: return
	
	var input_event: InputEvent = encode_event(event_dict)
	InputMap.action_add_event(input_name, input_event)

static func clear_binding(action: String, player_id: int):
	var input_name: String = action
	if player_id > -1:
		input_name += str(player_id)
	
	if InputMap.has_action(input_name):
		InputMap.action_erase_events(input_name)

static func add_from_binding_array(action: String, player_id: int, event_array: Array):
	# just want to create the inputmap actions even
	# if it's unbound, to prevent any errors
	add_binding(action, player_id, EMPTY_DICTIONARY)
	for event_dict in event_array:
		add_binding(action, player_id, event_dict)


## misc
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
