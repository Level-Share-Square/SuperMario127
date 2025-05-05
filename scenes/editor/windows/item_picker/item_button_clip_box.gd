extends Control


var pressed_offset := Vector2(0, 2)


func _button_down():
	rect_position += pressed_offset


func _button_up():
	rect_position -= pressed_offset
