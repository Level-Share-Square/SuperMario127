extends EditorTool


var last_mouse_tile: Vector2


func _click(_event: InputEvent, _world_pos: Vector2) -> void:
	if editor.selected_item is PlaceableTile:
		if Input.is_action_just_pressed("place"):
			draw_tile(last_mouse_tile)
	elif editor.selected_item is PlaceableObject:
		if Input.is_action_just_pressed("place"):
			place_object(_world_pos)


func _click_released(_event: InputEvent, _world_pos: Vector2) -> void:
	if editor.selected_item is PlaceableTile:
		finalize_placement()


func _mouse_movement(_event: InputEvent, world_pos: Vector2) -> void:
	var mouse_tile: Vector2 = (world_pos / editor.TILE_SIZE).floor()
	
	var line: = line_util.get_line(last_mouse_tile, mouse_tile)
	
	if Input.is_action_pressed("place"):
		for point in line:
			draw_tile(point)
	
#	if Input.is_action_pressed("erase"):
#		for point in line:
#			draw_tile(point)
	
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
	var cache_tile = shared.tilemaps_node.get_tile(item.tileset_id, item.tile_id, item.palette)
	
	if editor.tile_buffer.get_cell(pos.x, pos.y) == TileMap.INVALID_CELL:
		editor.tile_buffer.set_cellv(pos, cache_tile)
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


func place_object(pos: Vector2):
	var object_item: PlaceableObject = editor.selected_item
	var data = create_object_data(pos.snapped(Vector2(8, 8)), object_item.object_id, object_item.palette)
	
	var action := PlaceObjectAction.new()
	action.shared = shared
	action.object_data = data
	editor.action_manager.commit_action(action)
	
	
#	elif Input.is_action_pressed("erase"):
#		for object in editor.hovered_objects.values():
#			editor.hovered_objects.erase(object.name)
#			shared.destroy_object(object, true)
#			break


func create_object_data(position: Vector2, object_id: int, palette: int) -> ObjectData:
	var data = ObjectData.new()
	data.type_id = object_id
	data.palette = palette
	data.properties.append(position)
	data.properties.append(Vector2(1, 1))
	data.properties.append(0)
	data.properties.append(true)
	data.properties.append(true)
	data.properties.append(LevelShared.Layers.Middle)
	
	return data
