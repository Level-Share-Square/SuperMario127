extends ParallaxBackground

func _unhandled_input(event):
	if event.is_action_pressed("toggle_grid"):
		$Layer.visible = !$Layer.visible
