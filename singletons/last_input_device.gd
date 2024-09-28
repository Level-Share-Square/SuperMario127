extends Node


var class_type_map: Dictionary = {
	"InputEventKey": InputType.Keyboard,
	"InputEventMouseButton": InputType.Keyboard,
	"InputEventJoypadButton": InputType.Controller,
	"InputEventJoypadMotion": InputType.Controller,
	"InputEventScreenTouch": InputType.Touch,
	"InputEventScreenDrag": InputType.Touch,
	"InputEventGesture": InputType.Touch,
	"InputEventPanGesture": InputType.Touch
}

enum InputType {Keyboard, Controller, Touch}
var last_input_type: int = InputType.Keyboard


func _input(event):
	var class_string: String = event.get_class()
	if class_string in class_type_map.keys():
		last_input_type = class_type_map.get(event.get_class(), InputType.Keyboard)
