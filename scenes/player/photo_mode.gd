extends CanvasLayer

func _input(event):
	if event.is_action_pressed("30_fps") and !(get_tree().paused and !PhotoMode.enabled):
		PhotoMode.enabled = !PhotoMode.enabled
		update_photo_mode()
	
func update_photo_mode():
	var is_photo_mode = PhotoMode.enabled
	offset.y = 1000000 if is_photo_mode else 0 # hax
	get_tree().paused = is_photo_mode
