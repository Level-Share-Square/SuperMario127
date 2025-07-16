extends Panel


export var pressed_offset := Vector2(0, 2)
var toggle = false
var toggle_state = false


func _button_down():
	if "ItemSelectButton" in get_parent().name:
		get_parent().emit_signal("item_selected", get_parent().placeable_item)
	if toggle:
		rect_position += pressed_offset * (Vector2(-1, -1) if toggle_state else Vector2.ONE)
	else:
		rect_position += pressed_offset
	
	add_stylebox_override("panel", get_parent().get_stylebox("pressed"))


func _button_up():
	if toggle:
		rect_position -= pressed_offset * (Vector2(-1, -1) if not toggle_state else Vector2.ONE)
	else:
		rect_position -= pressed_offset
	
	add_stylebox_override("panel", get_parent().get_stylebox("normal"))


func _toggle(value: bool):
	toggle_state = value
	
	if value:
		rect_position += pressed_offset
	else:
		rect_position -= pressed_offset
