extends SpinBoxSound


signal done_editing

var is_dragging: bool


func _is_pos_in_spinbox(check_pos : Vector2):
	var gr = get_global_rect()
	var line_gr = get_line_edit().get_global_rect()
	gr.position.x += line_gr.size.x
	gr.size.x -= line_gr.size.x
	return (check_pos.x >= gr.position.x and check_pos.y >= gr.position.y 
		and check_pos.x < gr.end.x and check_pos.y < gr.end.y)


func _is_pos_in_line_edit(check_pos : Vector2):
	var gr = get_line_edit().get_global_rect()
	return (check_pos.x >= gr.position.x and check_pos.y >= gr.position.y 
		and check_pos.x < gr.end.x and check_pos.y < gr.end.y)


func _input(event):
	if not is_visible_in_tree(): return
	if event is InputEventMouseButton:
		if event.pressed and not _is_pos_in_line_edit(event.position) and get_focus_owner() == get_line_edit():
			get_line_edit().release_focus()
			emit_signal("done_editing")
		
		if event.pressed and _is_pos_in_spinbox(event.position):
			is_dragging = true
		elif not event.pressed and is_dragging:
			is_dragging = false
			emit_signal("done_editing")
