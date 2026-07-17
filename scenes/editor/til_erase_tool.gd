extends EditorTool

var last_mouse_tile: Vector2
var mouse_input: int = -1


func _click_left(_event: InputEvent, _world_pos: Vector2) -> void:
	if mouse_input > -1:
		return
	
	if Input.is_action_just_pressed("LMB"):
		last_mouse_tile = get_mouse_tile_pos()
		erase_tile(last_mouse_tile)
		mouse_input = 1


func _click_left_released(_event: InputEvent, _world_pos: Vector2) -> void:
	if editor.selected_item is PlaceableTile:
		if Input.is_action_just_released("LMB") and mouse_input == 1:
			finalize_erase()
			mouse_input = -1


func _mouse_movement(_event: InputEvent, world_pos: Vector2) -> void:
	if editor.selected_item is PlaceableTile:
		var mouse_tile: Vector2 = get_mouse_tile_pos()
		var line: = line_util.get_line(last_mouse_tile, mouse_tile)
		
		if Input.is_action_pressed("LMB") and mouse_input == 1:
			for point in line:
				erase_tile(point)
		
		last_mouse_tile = mouse_tile


func erase_tile(pos: Vector2) -> void:
	var level_bounds: Rect2 = CurrentLevelData.area.header.bounds
	if not level_bounds.has_point(pos):
		return
	
	var item = editor.selected_item
	var visual = tile_util.get_real_tile_set_id(21, 0, 2)
	
	if editor.tile_buffer.get_cell(pos.x, pos.y) == TileMap.INVALID_CELL:
		editor.tile_buffer.set_cellv(pos, visual)
		editor.tile_buffer.update_bitmask_area(pos)


func finalize_erase() -> void:
	var action := PlaceTilesAction.new()
	action.shared = shared
	action.layer = editor.layer
	action.tileset_id = 0
	action.tile_id = 0
	action.palette = 0
	action.do_tiles = editor.tile_buffer.get_used_cells()
	editor.action_manager.commit_action(action)
	
	editor.tile_buffer.clear()

# Mouse coords to tile grid coords
func get_mouse_tile_pos() -> Vector2:
	return (get_global_mouse_position() / editor.TILE_SIZE).floor()
	
	
