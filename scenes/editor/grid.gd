extends ParallaxBackground


var hidden: bool = false
var camera_zoom_level: float = 1.0


# Called when the node enters the scene tree for the first time.
func _unhandled_input(event):
	if Input.is_action_just_pressed("toggle_grid"):
		toggle_grid(!hidden)


func toggle_grid(value: bool):
	hidden = value
	update_visibility(camera_zoom_level)


func update_visibility(zoom_level: float):
	camera_zoom_level = zoom_level
	
	if zoom_level > 4:
		visible = false
	else:
		visible = hidden
