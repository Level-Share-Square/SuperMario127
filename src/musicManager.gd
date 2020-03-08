extends AudioStreamPlayer

func _process(_delta):
	var paused = get_tree().paused
	stream_paused = paused
	pass
