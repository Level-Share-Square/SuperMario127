extends CenterContainer

export (Array, NodePath) var category_paths

const INPUT_WAIT_TEXT: String = "Waiting..."

onready var current_category: Control = $Gameplay
var listening_keybind: KeybindButton
var is_controller: bool = false


func _ready():
	is_controller = LastInputDevice.last_input_type == LastInputDevice.InputType.Controller
	load_all_keybinds()


func _input(event: InputEvent):
	if not is_instance_valid(listening_keybind): return
	if not input_event_util.is_valid_input_event(event.get_class(), is_controller): return
	if listening_keybind.force_ctrl and event is InputEventKey:
		if OS.get_scancode_string(event.scancode) == "Control": return
	
	var action: Dictionary = input_event_util.decode_event(event)
	if action == input_event_util.EMPTY_DICTIONARY:
		return
	
	input_util.add_to_keybind(
		action, 
		[listening_keybind.input_group, listening_keybind.input_key, listening_keybind.player_id], 
		is_controller)
		
	get_tree().set_input_as_handled()
	listening_keybind.change_button_text()
	listening_keybind = null


func reset_keybind(keybind: VBoxContainer):
	input_util.reset_keybind(
		[keybind.input_group, keybind.input_key, keybind.player_id],
		is_controller
	)
	keybind.change_button_text()


func load_all_keybinds():
	for i in range(category_paths.size()):
		var category: Container = get_node(category_paths[i])
		load_category(category)


func load_category(category: Container):
	for keybind in category.get_children():
		if keybind is KeybindButton:
			var keybind_array: Array = [] 
			keybind_array += input_settings_util.get_setting(keybind.input_group, keybind.input_key)
			input_map_util.clear_input(keybind.input_key, keybind.player_id)
			input_map_util.add_input_from_array(keybind.input_key, keybind.player_id, keybind_array, keybind.input_group)
			
			keybind.is_controller = is_controller
			keybind.change_button_text()


func start_listening(keybind: KeybindButton, parent: GridContainer):
	for child in parent.get_children():
		if child is KeybindButton:
			child.change_button_text()
			
	keybind.change_button_text(INPUT_WAIT_TEXT)
	
	# let's not pick up the key that pressed the button
	yield(get_tree(), "idle_frame")
	listening_keybind = keybind


func switch_device_type(_is_controller: bool):
	is_controller = _is_controller
	listening_keybind = null
	load_all_keybinds()
