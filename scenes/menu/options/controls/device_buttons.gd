extends VBoxContainer


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
