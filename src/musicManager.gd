extends AudioStreamPlayer

func _process(_delta):
	var paused = get_tree().paused
	stream_paused = paused
	pass
	
func _input(event):
	if event.is_action_pressed("mute"):
		if volume_db == 0:
			volume_db = -80
		else:
			volume_db = 0
