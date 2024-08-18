extends CenterContainer

export (Array, NodePath) var category_paths

const INPUT_WAIT_TEXT: String = "Waiting..."

onready var current_category: Control = $Player1
var listening_keybind: VBoxContainer
var is_controller: bool = false

func _ready():
	load_all_bindings()

func _input(event: InputEvent):
	if not is_instance_valid(listening_keybind): return
	if not bindings_util.is_valid_input_event(event.get_class(), is_controller): return
	
	var binding_array: Array = LocalSettings.load_setting(listening_keybind.input_group, listening_keybind.input_key, [])
	var action: Dictionary = bindings_util.decode_event(event)
	if action == bindings_util.EMPTY_DICTIONARY:
		return
	
	# ensure there aren't duplicate inputs
	var duplicate_found: bool = false
	for binding in binding_array:
		if action.hash() == binding.hash():
			duplicate_found = true
			break
	
	if not duplicate_found: 
		binding_array.append(action)
		bindings_util.add_binding(listening_keybind.input_key, listening_keybind.player_id, action)
		LocalSettings.change_setting(listening_keybind.input_group, listening_keybind.input_key, binding_array)
		
	listening_keybind.change_button_text()
	get_tree().set_input_as_handled()
	listening_keybind = null



func start_listening(keybind: VBoxContainer, parent: GridContainer):
	for child in parent.get_children():
		if child is KeybindButton:
			child.change_button_text()
			
	keybind.change_button_text(INPUT_WAIT_TEXT)
	
	# let's not pick up the key that pressed the button
	yield(get_tree(), "idle_frame")
	listening_keybind = keybind

func reset_keybind(keybind: VBoxContainer):
	bindings_util.clear_binding(keybind.input_key, keybind.player_id)
	LocalSettings.change_setting(keybind.input_group, keybind.input_key, [])
	keybind.change_button_text()

func load_all_bindings():
	for i in range(category_paths.size()):
		var category: GridContainer = get_node(category_paths[i])
		
		for keybind in category.get_children():
			if keybind is KeybindButton:
				var binding_array: Array = LocalSettings.load_setting(keybind.input_group, keybind.input_key, [])
				bindings_util.clear_binding(keybind.input_key, keybind.player_id)
				bindings_util.add_from_binding_array(keybind.input_key, keybind.player_id, binding_array)
				keybind.change_button_text()
