extends SpinBoxSound


func _is_pos_in(check_pos : Vector2):
	var gr = get_line_edit().get_global_rect()
	return (check_pos.x >= gr.position.x and check_pos.y >= gr.position.y 
		and check_pos.x < gr.end.x and check_pos.y < gr.end.y)


func _input(event):
	if get_focus_owner() == get_line_edit() and event is InputEventMouseButton and event.pressed and not _is_pos_in(event.position):
		get_line_edit().release_focus()


func _ready():
	get_line_edit().connect("text_entered", self, "text_entered")


func text_entered(_new_text: String = "") -> void:
	get_line_edit().release_focus()
	
