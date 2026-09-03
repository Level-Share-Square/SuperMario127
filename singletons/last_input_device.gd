extends Node


signal input_type_changed(new_input_type)
signal mouse_changed(is_mouse)


var class_type_map: Dictionary = {
	"InputEventKey": InputType.Keyboard,
	"InputEventJoypadButton": InputType.Controller,
	"InputEventJoypadMotion": InputType.Controller,
	"InputEventScreenTouch": InputType.Touch,
	"InputEventScreenDrag": InputType.Touch,
	"InputEventGesture": InputType.Touch,
	"InputEventPanGesture": InputType.Touch
}

enum InputType {Keyboard, Controller, Touch}
enum LayoutType {Xbox, Nintendo, PlayStation}
var last_input_type: int = InputType.Keyboard
var last_layout_type: int = LayoutType.Xbox
var is_mouse: bool
var last_controller: int = 0

var layouts_regex: Dictionary = {
	LayoutType.Nintendo: [
		"(?i)Wii", "(?i)S?NES", "(?i)Switch", "(?i)Joy[- ]Con"
	],
	LayoutType.PlayStation: [
		".*PS\\d.*", "(?i)Sony.*", "(?i)Play[Ss]tation"
	]
}

func _input(event):
	if not "device" in event or event.device != -1:
		var last_mouse: bool = is_mouse
		is_mouse = (event is InputEventMouseMotion or event is InputEventMouseButton)
		if is_mouse != last_mouse:
			emit_signal("mouse_changed", is_mouse)
	
	if event.device != -1 and (event is InputEventJoypadButton or event is InputEventJoypadMotion): last_controller = event.device
	
	var class_string: String = event.get_class()
	if class_string in class_type_map.keys():
		var new_input_type: int = class_type_map.get(event.get_class(), InputType.Keyboard)
		
		if new_input_type == InputType.Controller:
			var new_layout_type: int = LayoutType.Xbox
			for layout_type in layouts_regex.keys():
				for regex_string in layouts_regex[layout_type]:
					var regex := RegEx.new()
					regex.compile(regex_string)
					var result: RegExMatch = regex.search(Input.get_joy_name(event.device))
					if result:
						new_layout_type = layout_type
			last_layout_type = new_layout_type
		
		if new_input_type != last_input_type:
			emit_signal("input_type_changed", new_input_type)
		
		last_input_type = new_input_type

func rumble(weak_power: float, strong_power: float, time: float):
	if not last_input_type == InputType.Controller: return
	Input.start_joy_vibration(last_controller, weak_power, strong_power, time)
