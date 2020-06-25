extends Sprite

func _ready():
	var editor = get_parent()
	update_preview(editor.selected_box.item)

func update_preview(item: Node):
	if item:
		texture = load(item.preview.load_path)

func _process(_delta):
	var editor = get_parent()
	var selected_box = editor.selected_box
	if selected_box:
		if selected_box.item:
			var item = selected_box.item
			var mouse_pos = get_global_mouse_position()
			var mouse_tile_pos = Vector2(floor(mouse_pos.x / item.tile_mode_step), floor(mouse_pos.y / item.tile_mode_step))
			var mouse_grid_pos = Vector2((mouse_tile_pos.x * item.tile_mode_step) + (item.tile_mode_step / 2), (mouse_tile_pos.y * item.tile_mode_step) + (item.tile_mode_step / 2))
			
			z_index = item.z_index
			if editor.placement_mode == "Tile" or !item.is_object:
				position = mouse_grid_pos + item.tile_mode_offset
			else:
				if Input.is_action_pressed("8_pixel_lock"):
					mouse_pos = Vector2(stepify(mouse_pos.x, 8), stepify(mouse_pos.y, 8))
				if editor.surface_snap:
					var object_bottom = mouse_pos + Vector2(0, item.object_size.y)
					var space_state = get_world_2d().direct_space_state
					var result = space_state.intersect_ray(object_bottom, object_bottom + Vector2(0, 16))
					if result:
						mouse_pos = result.position - Vector2(0, item.object_size.y)
				position = mouse_pos
	if editor.dragging_item != null or editor.display_preview_item == false or editor.selected_tool != 0:
		visible = false
	else:
		visible = true
