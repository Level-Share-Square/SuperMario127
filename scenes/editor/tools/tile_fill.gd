extends EditorTool

var is_erasing: bool
var undo_tiles: Dictionary = {}

func _click_left(_event: InputEvent, _world_pos: Vector2) -> void:
	is_erasing = tool_manager.is_erasing
	draw_tile(get_mouse_tile_pos())
	
func _click_right(_event: InputEvent, _world_pos: Vector2) -> void:
	is_erasing = not tool_manager.is_erasing
	draw_tile(get_mouse_tile_pos())

func draw_tile(pos: Vector2) -> void:
	var level_bounds: Rect2 = CurrentLevelData.current_area.header.bounds
	if not level_bounds.has_point(pos):
		return
	undo_tiles = {}
	cache_tile(pos.x, pos.y)
	fill_place(pos.x, pos.y)
		

func fill_place(pos_x, pos_y):
	var level_bounds: Rect2 = CurrentLevelData.current_area.header.bounds
	var item = editor.selected_item
	var tile_to_fill = shared.get_tile(pos_x, pos_y, editor.layer)
	var selected_tile = [item.tileset_id, item.tile_id, item.palette]
	var cells := [Vector2(pos_x, pos_y)]
	while cells:
		var current_cell: Vector2 = cells.pop_back()
		
		var first_tile = shared.get_tile(current_cell.x - 1, current_cell.y, editor.layer)
		if (first_tile == tile_to_fill and not is_erasing or first_tile != [0, 0, 0] and is_erasing) && editor.tile_buffer.get_cell(current_cell.x - 1, current_cell.y) == TileMap.INVALID_CELL && level_bounds.has_point(Vector2(current_cell.x - 1, current_cell.y)):
			cache_tile(current_cell.x - 1, current_cell.y)
			cells.append( Vector2(current_cell.x - 1, current_cell.y) )
	
		var second_tile = shared.get_tile(current_cell.x + 1, current_cell.y, editor.layer)
		if (second_tile == tile_to_fill and not is_erasing or second_tile != [0, 0, 0] and is_erasing) && editor.tile_buffer.get_cell(current_cell.x + 1, current_cell.y) == TileMap.INVALID_CELL && level_bounds.has_point(Vector2(current_cell.x + 1, current_cell.y)):
			cache_tile(current_cell.x + 1, current_cell.y)
			cells.append( Vector2(current_cell.x + 1, current_cell.y) )

		var third_tile = shared.get_tile(current_cell.x, current_cell.y - 1, editor.layer)
		if (third_tile == tile_to_fill and not is_erasing or third_tile != [0, 0, 0] and is_erasing) && editor.tile_buffer.get_cell(current_cell.x, current_cell.y - 1) == TileMap.INVALID_CELL && level_bounds.has_point(Vector2(current_cell.x, current_cell.y - 1)):
			cache_tile(current_cell.x, current_cell.y - 1)
			cells.append( Vector2(current_cell.x, current_cell.y - 1) )

		var fourth_tile = shared.get_tile(current_cell.x, current_cell.y + 1, editor.layer)
		if (fourth_tile == tile_to_fill and not is_erasing or fourth_tile != [0, 0, 0] and is_erasing) && editor.tile_buffer.get_cell(current_cell.x, current_cell.y + 1) == TileMap.INVALID_CELL && level_bounds.has_point(Vector2(current_cell.x, current_cell.y + 1)):
			cache_tile(current_cell.x, current_cell.y + 1)
			cells.append( Vector2(current_cell.x, current_cell.y + 1))
		
		undo_tiles.get_or_add(current_cell, shared.get_tile(current_cell.x, current_cell.y, editor.layer))
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
	action.tileset_id = editor.selected_item.tileset_id if not is_erasing else 0
	action.tile_id = editor.selected_item.tile_id if not is_erasing else 0
	action.palette = editor.selected_item.palette if not is_erasing else 0
	action.do_tiles = editor.tile_buffer.get_used_cells()
	action.undo_tiles = undo_tiles.duplicate()
	editor.action_manager.commit_action(action)
	
	editor.tile_buffer.clear()
	undo_tiles.clear()

# Mouse coords to tile grid coords
func get_mouse_tile_pos() -> Vector2:
	return (get_mouse_pos() / editor.TILE_SIZE).floor()
	
	

