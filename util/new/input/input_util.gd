class_name input_util


static func add_to_keybind(event: Dictionary, keybind_info: Array, is_controller: bool):
	var input_group: String = keybind_info[0]
	var input_key: String = keybind_info[1]
	var player_id: int = keybind_info[2]
	
	var keybind_array: Array = input_settings_util.get_setting_partial(input_group, input_key, is_controller)

	# ensure there aren't duplicate inputs
	var duplicate_found: bool = false
	for keybind in keybind_array:
		if event.hash() == keybind.hash():
			duplicate_found = true
			break
	
	if not duplicate_found: 
		keybind_array.append(event)
		input_map_util.add_input(input_key, player_id, event)
		input_settings_util.change_setting(input_group, input_key, keybind_array, is_controller)


static func reset_keybind(keybind_info: Array, is_controller: bool):
	var input_group: String = keybind_info[0]
	var input_key: String = keybind_info[1]
	var player_id: int = keybind_info[2]
	
	input_map_util.clear_input(input_key, player_id)
	input_settings_util.change_setting(input_group, input_key, [], is_controller)
	
	# if you clear the controller keybinds... it should still have the keyboard ones and vice versa
	var keybind_array: Array = []
	keybind_array += input_settings_util.get_setting_partial(input_group, input_key, not is_controller)
	input_map_util.add_input_from_array(input_key, player_id, keybind_array)

