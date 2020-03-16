extends Sprite

func update_preview(item: Node):
	if item:
		texture = item.preview

func _process(delta):
	var mouse_pos = get_global_mouse_position()
	var mouse_screen_pos = get_viewport().get_mouse_position()
	var mouse_tile_pos = Vector2(floor(mouse_pos.x / 32), floor(mouse_pos.y / 32))
	var mouse_grid_pos = Vector2((mouse_tile_pos.x * 32) + 16, (mouse_tile_pos.y * 32) + 16)
	position = mouse_grid_pos
