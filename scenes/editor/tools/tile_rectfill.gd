extends Selector

func on_mouse_released():
	if !.on_mouse_released():
		return
		
	hide_visuals()
	
	var tile_fill_rect := Rect2(get_tile_grid_position(fill_rect.position), get_tile_grid_position(fill_rect.size))
	
	for x in range(tile_fill_rect.position.x, tile_fill_rect.position.x + tile_fill_rect.size.x):
		for y in range(tile_fill_rect.position.y, tile_fill_rect.position.y + tile_fill_rect.size.y):
			draw_tile(Vector2(x, y))
	finalize_placement()
	reset_bounds()
	
func draw_tile(pos: Vector2) -> void:
	var item = editor.selected_item
	var cache_tile = tile_util.get_real_tile_set_id(item.tileset_id, item.tile_id, item.palette)
	
	if editor.tile_buffer.get_cell(pos.x, pos.y) == TileMap.INVALID_CELL:
		editor.tile_buffer.set_cellv(pos, cache_tile)
		editor.tile_buffer.update_bitmask_area(pos)

func finalize_placement() -> void:
	var undo_tiles: Dictionary = {}
	for pos in editor.tile_buffer.get_used_cells():
		undo_tiles.get_or_add(pos, shared.get_tile(pos.x, pos.y, editor.layer))
	var action := PlaceTilesAction.new()
	action.shared = shared
	action.layer = editor.layer
	action.tileset_id = editor.selected_item.tileset_id
	action.tile_id = editor.selected_item.tile_id
	action.palette = editor.selected_item.palette
	action.do_tiles = editor.tile_buffer.get_used_cells()
	action.undo_tiles = undo_tiles
	editor.action_manager.commit_action(action)
	
	editor.tile_buffer.clear()
