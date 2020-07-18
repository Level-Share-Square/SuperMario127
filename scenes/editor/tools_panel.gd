extends Panel

export var editor : NodePath
onready var editor_node = get_node(editor)

func _process(_delta):
	var mouse_pos = get_viewport().get_mouse_position()
	if mouse_pos.x > rect_position.x and mouse_pos.x < rect_position.x + rect_size.x:
		if mouse_pos.y > rect_position.y and mouse_pos.y < rect_position.y + rect_size.y:
			editor_node.display_preview_item = false
		else:
			editor_node.display_preview_item = true
	else:
		editor_node.display_preview_item = true
