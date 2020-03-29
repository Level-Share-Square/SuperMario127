extends LineEdit

func _input(event):
	if event.is_action_pressed("text_release_focus"): # this should already be a thing
		release_focus()
