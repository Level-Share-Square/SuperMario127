extends Selector

var is_erasing: bool

func _click_left(event, mouse_position):
	._click_left(event, mouse_position)
	is_erasing = tool_manager.is_erasing
		
func _click_left_released(event, mouse_position):
	._click_left_released(event, mouse_position)
	is_erasing = tool_manager.is_erasing
	
func _click_right(_event, _world_pos) -> void:
	is_dragging = true
	set_highlight_mode(true)
	reset_bounds()
	start_pos = get_adjusted_mouse_position()
	on_selection_outside_clicked()
	
	is_erasing = not tool_manager.is_erasing
	
func _click_right_released(_event, _mouse_position) -> void:
	is_dragging = false
	set_highlight_mode(false)
	on_mouse_released()
	is_erasing = not tool_manager.is_erasing

func on_mouse_released():
	if !.on_mouse_released():
		return
		
	hide_visuals()
	finalize_placement()
	reset_bounds()
	
func box_expansion():
	.box_expansion()
	var tile_fill_rect := Rect2(get_tile_grid_position(fill_rect.position), get_tile_grid_position(fill_rect.size))
	
	var update_bitmask: bool = false
	
	for cell in editor.tile_buffer.get_used_cells():
		if not tile_fill_rect.has_point(cell):
			editor.tile_buffer.set_cellv(cell, -1)
			update_bitmask = true
	
	for x in range(tile_fill_rect.position.x, tile_fill_rect.position.x + tile_fill_rect.size.x):
		for y in range(tile_fill_rect.position.y, tile_fill_rect.position.y + tile_fill_rect.size.y):
			var pos := Vector2(x, y)
			
			if not is_tile_cached(pos):
				cache_tile(pos)
				update_bitmask = true
				
	if update_bitmask:
		editor.tile_buffer.update_bitmask_region()
	
func cache_tile(pos: Vector2) -> void:
	var item = editor.selected_item
	var cache_tile = tile_util.get_real_tile_set_id(item.tileset_id, item.tile_id, item.palette)
	
	if editor.tile_buffer.get_cell(pos.x, pos.y) == TileMap.INVALID_CELL:
		editor.tile_buffer.set_cellv(pos, cache_tile)
		editor.tile_buffer.update_bitmask_area(pos)
		
func is_tile_cached(pos: Vector2) -> bool:
	return editor.tile_buffer.get_cellv(pos) != -1

func finalize_placement() -> void:
	var undo_tiles: Dictionary = {}
	for pos in editor.tile_buffer.get_used_cells():
		undo_tiles.get_or_add(pos, shared.get_tile(pos.x, pos.y, editor.layer))
	var action := PlaceTilesAction.new()
	action.shared = shared
	action.layer = editor.layer
	action.tileset_id = editor.selected_item.tileset_id if not is_erasing else 0
	action.tile_id = editor.selected_item.tile_id if not is_erasing else 0
	action.palette = editor.selected_item.palette if not is_erasing else 0
	action.do_tiles = editor.tile_buffer.get_used_cells()
	action.undo_tiles = undo_tiles
	editor.action_manager.commit_action(action)
	
	editor.tile_buffer.clear()
