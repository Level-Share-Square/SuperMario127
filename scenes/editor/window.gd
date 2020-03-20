extends NinePatchRect

onready var close_button = $CloseButton
var drag_position = null

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			drag_position = get_global_mouse_position() - rect_global_position
			raise()
		else:
			drag_position = null
	if event is InputEventMouseMotion and drag_position:
		rect_global_position = get_global_mouse_position() - drag_position

func _process(delta):
	if close_button.pressed:
		visible = false
