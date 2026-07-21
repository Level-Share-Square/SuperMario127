extends EditorTool

func _click_left(_event: InputEvent, _world_pos: Vector2) -> void:
	draw_tile(get_mouse_tile_pos())


func draw_tile(pos: Vector2) -> void:
	var level_bounds: Rect2 = CurrentLevelData.current_area.header.bounds
	if not level_bounds.has_point(pos):
		return
	
	cache_tile(pos.x, pos.y)
	fill_place(pos.x, pos.y)
		

func fill_place(pos_x, pos_y):
	var level_bounds: Rect2 = CurrentLevelData.current_area.header.bounds
	var empty_tile = [0,0,0]
	var cells := [Vector2(pos_x, pos_y)]
	while cells:
		var current_cell: Vector2 = cells.pop_back()
		
		
		if shared.get_tile(current_cell.x - 1, current_cell.y, editor.layer) == empty_tile && editor.tile_buffer.get_cell(current_cell.x - 1, current_cell.y) == TileMap.INVALID_CELL && level_bounds.has_point(Vector2(current_cell.x - 1, current_cell.y)):
			cache_tile(current_cell.x - 1, current_cell.y)
			cells.append( Vector2(current_cell.x - 1, current_cell.y) )
	
		if shared.get_tile(current_cell.x + 1, current_cell.y, editor.layer) == empty_tile && editor.tile_buffer.get_cell(current_cell.x + 1, current_cell.y) == TileMap.INVALID_CELL && level_bounds.has_point(Vector2(current_cell.x + 1, current_cell.y)):
			cache_tile(current_cell.x + 1, current_cell.y)
			cells.append( Vector2(current_cell.x + 1, current_cell.y) )

		if shared.get_tile(current_cell.x, current_cell.y - 1, editor.layer) == empty_tile && editor.tile_buffer.get_cell(current_cell.x, current_cell.y - 1) == TileMap.INVALID_CELL && level_bounds.has_point(Vector2(current_cell.x, current_cell.y - 1)):
			cache_tile(current_cell.x, current_cell.y - 1)
			cells.append( Vector2(current_cell.x, current_cell.y - 1) )

		if shared.get_tile(current_cell.x, current_cell.y + 1, editor.layer) == empty_tile && editor.tile_buffer.get_cell(current_cell.x, current_cell.y + 1) == TileMap.INVALID_CELL && level_bounds.has_point(Vector2(current_cell.x, current_cell.y + 1)):
			cache_tile(current_cell.x, current_cell.y + 1)
			cells.append( Vector2(current_cell.x, current_cell.y + 1))

	finalize_placement()

func cache_tile(pos_x, pos_y):
	var item = editor.selected_item
	var cache_tile = tile_util.get_real_tile_set_id(item.tileset_id, item.tile_id, item.palette)
	if editor.tile_buffer.get_cell(pos_x, pos_y) == TileMap.INVALID_CELL:
		editor.tile_buffer.set_cellv(Vector2(pos_x, pos_y), cache_tile)
		editor.tile_buffer.update_bitmask_area(Vector2(pos_x, pos_y))

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
	return (get_global_mouse_position() / editor.TILE_SIZE).floor()
	
	

