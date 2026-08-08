extends TextEdit

onready var modifiers = $"%Modifiers"


func wrap_in_bbcode(string: String, bbcode: String, arguments: String = "") -> String:
	return "[" + bbcode + arguments + "]" + string + "[/" + bbcode + "]"


func add_bbcode(bbcode: String, arguments: String = "") -> void:
	if is_selection_active():
		var selected_text: String = get_selection_text()
		var wrapped_text: String = wrap_in_bbcode(selected_text, bbcode, arguments)
		insert_text_at_cursor(wrapped_text)
	else:
		var wrapped_text: String = wrap_in_bbcode("", bbcode, arguments)
		insert_text_at_cursor(wrapped_text)


func add_string(string: String) -> void:
	insert_text_at_cursor(string)


func _is_pos_in(check_pos : Vector2):
	var self_gr: Rect2 = get_global_rect()
	var modifier_gr: Rect2 = modifiers.get_global_rect()
	var gr: Rect2 = modifier_gr.merge(self_gr)
	return (check_pos.x >= gr.position.x and check_pos.y >= gr.position.y 
		and check_pos.x < gr.end.x and check_pos.y < gr.end.y)


func _input(event):
	if event is InputEventMouseButton and not _is_pos_in(event.position):
		release_focus()
