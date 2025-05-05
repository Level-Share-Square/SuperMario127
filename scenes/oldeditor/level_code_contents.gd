extends TextEdit

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 2 and event.pressed:
			text = OS.clipboard
