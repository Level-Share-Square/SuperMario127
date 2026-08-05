extends EditorTool


var last_mouse_tile: Vector2
var mouse_input: int = -1


func _click_left(_event: InputEvent, _world_pos: Vector2) -> void:
#	print(shared.get_tile(9999, 9999, 2))
	if mouse_input > -1:
		return
	
	if Input.is_action_just_pressed("place"):
		last_mouse_tile = get_mouse_tile_pos()
		editor.tile_buffer.modulate = shared.layer_dictionary[editor.layer].layer_tint
		draw_tile(last_mouse_tile)
		mouse_input = 0


func _click_left_released(_event: InputEvent, _world_pos: Vector2) -> void:
	if editor.selected_item is PlaceableTile:
		if Input.is_action_just_released("place") and mouse_input == 0:
			finalize_placement()
			mouse_input = -1


func _mouse_movement(_event: InputEvent, world_pos: Vector2) -> void:
	if editor.selected_item is PlaceableTile:
		var mouse_tile: Vector2 = get_mouse_tile_pos()
		var line: = line_util.get_line(last_mouse_tile, mouse_tile)
		
		if Input.is_action_pressed("place") and mouse_input == 0:
			for point in line:
				draw_tile(point)
		
		last_mouse_tile = mouse_tile
#	print(last_mouse_tile)


func draw_tile(pos: Vector2) -> void:
	var item = editor.selected_item
	var cache_tile = tile_util.get_real_tile_set_id(item.tileset_id, item.tile_id, item.palette)
	
	if editor.tile_buffer.get_cell(pos.x, pos.y) == TileMap.INVALID_CELL:
		editor.tile_buffer.set_cellv(pos, cache_tile)
		editor.tile_buffer.update_bitmask_area(pos)


func finalize_placement() -> void:
	var action := PlaceTilesAction.new()
	action.shared = shared
	action.layer = editor.layer
	action.tileset_id = editor.selected_item.tileset_id
	action.tile_id = editor.selected_item.tile_id
	action.palette = editor.selected_item.palette
	action.do_tiles = editor.tile_buffer.get_used_cells()
	editor.action_manager.commit_action(action)
	
	editor.tile_buffer.clear()


# Mouse coords to tile grid coords
func get_mouse_tile_pos() -> Vector2:
	return (get_mouse_pos() / editor.TILE_SIZE).floor()
