class_name input_map_util


const EMPTY_DICTIONARY = {}


## functions that edit the actual control bindings
static func add_input(action: String, player_id: int, event_dict: Dictionary, input_group: String):
	var input_name: String = action
	if player_id > -1:
		input_name += str(player_id)
	
	if not InputMap.has_action(input_name):
		InputMap.add_action(input_name, input_event_util.DEADZONE)
	
	if event_dict == EMPTY_DICTIONARY: return
	
	var input_event: InputEvent = input_event_util.encode_event(event_dict)
	if input_event_util.is_controller_input(event_dict):
		input_event.device = input_settings_util.get_device(input_group)
	
	InputMap.action_add_event(input_name, input_event)


static func clear_input(action: String, player_id: int):
	var input_name: String = action
	if player_id > -1:
		input_name += str(player_id)
	
	if InputMap.has_action(input_name):
		InputMap.action_erase_events(input_name)


static func add_input_from_array(action: String, player_id: int, keybind_array: Array, input_group: String):
	# just want to create the inputmap actions even
	# if it's unbound, to prevent any errors
	add_input(action, player_id, EMPTY_DICTIONARY, input_group)
	for event_dict in keybind_array:
		add_input(action, player_id, event_dict, input_group)
