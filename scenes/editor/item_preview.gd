extends TextureRect

onready var editor = get_parent()

var is_object: bool = true

func _process(delta):
	var mouse_pos = get_global_mouse_position() - Vector2(16, 16)
	if is_object:
		if editor.pixel_lock:
			mouse_pos = Vector2(stepify(mouse_pos.x, 8), stepify(mouse_pos.y, 8))
	else:
		mouse_pos = Vector2(int(get_global_mouse_position().x / 32) * 32, int(get_global_mouse_position().y / 32) * 32)
	rect_global_position = mouse_pos

func update_item(item, palette, is_obj):
	texture = item.icons[palette]
	is_object = is_obj


func _on_Tools_tool_changed():
	if !"Paint" in editor.tool_manager.current_tool.name:
		hide()
	else:
		show()
