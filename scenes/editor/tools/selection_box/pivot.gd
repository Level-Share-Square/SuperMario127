extends TextureButton

onready var selection_box = get_parent()
onready var actual_box = selection_box.get_node("%SelectionBox")


func _process(delta):
	if pressed:
		rect_global_position = get_global_mouse_position()
		selection_box.pivot_position = rect_global_position
	elif selection_box.pivot_position != Vector2(0, 0):
		rect_global_position = selection_box.pivot_position

func on_toggle():
	print([rect_global_position, get_global_mouse_position()])
	var pivot_toggle = selection_box.pivot_toggle
	if pivot_toggle.pressed:
		hide()
		selection_box.pivot_position = Vector2.ZERO
	else:
		show()
		rect_global_position = Vector2(actual_box.rect_global_position.x + actual_box.rect_size.x/2, actual_box.rect_global_position.y + actual_box.rect_size.y/2)
		selection_box.pivot_position = rect_global_position

func reveal_thyself():
	selection_box.pivot_toggle.pressed = true
	show()
	yield(get_tree().create_timer(0.001), "timeout")
	rect_global_position = Vector2(actual_box.rect_global_position.x + actual_box.rect_size.x/2, actual_box.rect_global_position.y + actual_box.rect_size.y/2)
	selection_box.pivot_position = rect_global_position
	
func center_pivot():
	rect_global_position = Vector2(actual_box.rect_global_position.x + actual_box.rect_size.x/2, actual_box.rect_global_position.y + actual_box.rect_size.y/2)
	selection_box.pivot_position = rect_global_position
