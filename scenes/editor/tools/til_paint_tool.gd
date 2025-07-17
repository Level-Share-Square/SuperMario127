extends EditorTool


export var eraser_only: bool = false

var last_mouse_tile: Vector2
var mouse_input: int = -1


func _click_left(_event: InputEvent, _world_pos: Vector2) -> void:
	if eraser_only:
		return
	
	if mouse_input > -1:
		return
	
	if Input.is_action_just_pressed("place"):
		draw_tile(last_mouse_tile)
		mouse_input = 0


func _click_right(_event: InputEvent, _world_pos: Vector2) -> void:
	if mouse_input > -1:
		return
	
	if Input.is_action_just_pressed("erase"):
		erase_tile(last_mouse_tile)
		mouse_input = 1


func _click_left_released(_event: InputEvent, _world_pos: Vector2) -> void:
	if eraser_only:
		return
	
	if editor.selected_item is PlaceableTile:
		if Input.is_action_just_released("place") and mouse_input == 0:
			finalize_placement()
			mouse_input = -1


func _click_right_released(_event: InputEvent, _world_pos: Vector2) -> void:
	if editor.selected_item is PlaceableTile:
		if Input.is_action_just_released("erase") and mouse_input == 1:
			finalize_erase()
			mouse_input = -1


func _mouse_movement(_event: InputEvent, world_pos: Vector2) -> void:
	if editor.selected_item is PlaceableTile:
		var mouse_tile: Vector2 = (get_global_mouse_position() / editor.TILE_SIZE).floor()
		var line: = line_util.get_line(last_mouse_tile, mouse_tile)
		
		if not eraser_only:
			if Input.is_action_pressed("place") and mouse_input == 0:
				for point in line:
					draw_tile(point)
		
		if Input.is_action_pressed("erase") and mouse_input == 1:
			for point in line:
				erase_tile(point)
		
		last_mouse_tile = mouse_tile


func draw_tile(pos: Vector2) -> void:
	var level_bounds: Rect2 = Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings.bounds
	if not level_bounds.has_point(pos):
		return
	
	var item = editor.selected_item
	var cache_tile = shared.tilemaps_node.get_tile(item.tileset_id, item.tile_id, item.palette)
	
	if editor.tile_buffer.get_cell(pos.x, pos.y) == TileMap.INVALID_CELL:
		editor.tile_buffer.set_cellv(pos, cache_tile)
		editor.tile_buffer.update_bitmask_area(pos)


func erase_tile(pos: Vector2) -> void:
	var level_bounds: Rect2 = Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings.bounds
	if not level_bounds.has_point(pos):
		return
	
	var item = editor.selected_item
	var visual = shared.tilemaps_node.get_tile(21, 0, 2)
	
	if editor.tile_buffer.get_cell(pos.x, pos.y) == TileMap.INVALID_CELL:
		editor.tile_buffer.set_cellv(pos, visual)
		editor.tile_buffer.update_bitmask_area(pos)


func finalize_placement() -> void:
	var action := PlaceTilesAction.new()
	action.shared = shared
	action.layer = LevelShared.TileLayers.Middle
	action.tileset_id = editor.selected_item.tileset_id
	action.tile_id = editor.selected_item.tile_id
	action.palette = editor.selected_item.palette
	action.do_tiles = editor.tile_buffer.get_used_cells()
	editor.action_manager.commit_action(action)
	
	editor.tile_buffer.clear()


func finalize_erase() -> void:
	var action := PlaceTilesAction.new()
	action.shared = shared
	action.layer = LevelShared.TileLayers.Middle
	action.tileset_id = 0
	action.tile_id = 0
	action.palette = 0
	action.do_tiles = editor.tile_buffer.get_used_cells()
	editor.action_manager.commit_action(action)
	
	editor.tile_buffer.clear()
