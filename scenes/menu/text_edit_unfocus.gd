extends TextEdit


func _is_pos_in(check_pos : Vector2):
	var gr = get_global_rect()
	return (check_pos.x >= gr.position.x and check_pos.y >= gr.position.y 
		and check_pos.x < gr.end.x and check_pos.y < gr.end.y)


func _input(event):
	if event is InputEventMouseButton and not _is_pos_in(event.position):
		release_focus()
