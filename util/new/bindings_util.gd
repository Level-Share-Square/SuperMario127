class_name bindings_util

const EMPTY_DICTIONARY = {}

const KEYBOARD = 0
const MOUSE = 1
const JOYPAD_BUTTON = 2
const JOYPAD_MOTION = 3

const DEADZONE = 0.25

const UNKNOWN = "Unknown"

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
			input_event.axis_value = sign(dictionary.axis_value)
	
	return input_event

static func decode_event(event: InputEvent) -> Dictionary:
	var dictionary: Dictionary = {}
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		return EMPTY_DICTIONARY
	
	match event.get_class():
		"InputEventKey":
			dictionary["input_type"] = KEYBOARD
			dictionary["scancode"] = event.scancode
			print("Scancode: " + str(event.scancode))

		"InputEventMouseButton":
			dictionary["input_type"] = MOUSE
			dictionary["button_index"] = event.button_index
			print("Button index: " + str(event.button_index))
		
		"InputEventJoypadButton":
			dictionary["input_type"] = JOYPAD_BUTTON
			dictionary["button_index"] = event.button_index
			print("Button index: " + str(event.button_index))
		
		"InputEventJoypadMotion":
			if abs(event.axis_value) > DEADZONE:
				dictionary["input_type"] = JOYPAD_MOTION
				dictionary["axis"] = event.axis
				dictionary["axis_value"] = event.axis_value
				print("Axis: " + str(event.axis))
				print("Axis direction: " + str(sign(event.axis_value)))
			else:
				return EMPTY_DICTIONARY
	
	print("Device: " + str(event.device))
	return dictionary


## functions that edit the actual control bindings
static func add_binding(action: String, player_id: int, event_dict: Dictionary):
	var input_name: String = action
	if player_id > -1:
		input_name += str(player_id)
	
	var input_event: InputEvent = encode_event(event_dict)
	InputMap.action_add_event(input_name, input_event)
	InputMap.action_set_deadzone(input_name, DEADZONE)

static func clear_binding(action: String, player_id: int):
	var input_name: String = action
	if player_id > -1:
		input_name += str(player_id)
	
	InputMap.action_erase_events(input_name)
