extends VBoxContainer


onready var remapper = $"%Remapper"

onready var keyboard = $HBoxContainer/Keyboard
onready var controller = $HBoxContainer/Controller

onready var device_label = $HBoxContainer/DeviceLabel
onready var device = $HBoxContainer/Device

export var default_theme: String
export var selected_theme: String


func switch_device_type(is_controller: bool):
	keyboard.theme_type_variation = default_theme if is_controller else selected_theme
	controller.theme_type_variation = default_theme if not is_controller else selected_theme
	
	device_label.visible = is_controller
	device.visible = is_controller


func screen_opened(_category_name: String = ""):
	var category: String = remapper.current_category.get_child(0).input_group
	var current_device: int = input_settings_util.get_device(category)
	
	device.text = "Any"
	if current_device != -1:
		device.text = str(current_device)
	
	## okay this looks weird but basically this just starts u off as 
	## keyboard or controller depending on what u used last
	var is_controller: bool = LastInputDevice.last_input_type == LastInputDevice.InputType.Controller
	if is_controller:
		for connection in controller.get_signal_connection_list("pressed"):
			if not connection.target is ButtonSound:
				connection.target.callv(connection.method, connection.binds)
	else:
		for connection in keyboard.get_signal_connection_list("pressed"):
			if not connection.target is ButtonSound:
				connection.target.callv(connection.method, connection.binds)


func switch_device():
	var category: String = remapper.current_category.get_child(0).input_group
	
	var connected_joypads: Array = Input.get_connected_joypads()
	var current_device: int = input_settings_util.get_device(category)
	
	var array_index: int = -1
	if current_device in connected_joypads:
		array_index = connected_joypads.find(current_device)
	
	array_index = wrapi(array_index + 1, -1, connected_joypads.size())
	
	var new_device: int = -1
	if array_index != -1:
		new_device = connected_joypads[array_index]
	input_settings_util.change_device(category, new_device)
	remapper.load_category(remapper.current_category)
	
	device.text = "Any"
	if new_device != -1:
		device.text = str(new_device)
