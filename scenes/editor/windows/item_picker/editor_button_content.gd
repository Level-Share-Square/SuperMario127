extends Control


export var pressed_offset := Vector2(0, 2)
var toggle = false
var toggle_state = false


func _button_down():
	if toggle:
		rect_position += pressed_offset * (Vector2(-1, -1) if toggle_state else Vector2.ONE)
	else:
		rect_position += pressed_offset


func _button_up():
	if toggle:
		rect_position -= pressed_offset * (Vector2(-1, -1) if not toggle_state else Vector2.ONE)
	else:
		rect_position -= pressed_offset



func _toggle(value: bool):
	toggle_state = value
	
	if value:
		rect_position += pressed_offset
	else:
		rect_position -= pressed_offset
