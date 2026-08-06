extends EditorTool


var last_mouse_tile: Vector2
var mouse_input: int = -1
var used_tiles: Array = []
var undo_tiles: Dictionary = {}
var is_erasing: bool = false


func _click_left(_event: InputEvent, _world_pos: Vector2) -> void:
	if mouse_input > -1:
		return
	is_erasing = tool_manager.is_erasing
	click()


func _click_left_released(_event: InputEvent, _world_pos: Vector2) -> void:
	is_erasing = tool_manager.is_erasing
	click_released()


func _click_right(event: InputEvent, world_pos: Vector2) -> void:
	if mouse_input > -1:
		return
	is_erasing = not tool_manager.is_erasing
	click()


func _click_right_released(event: InputEvent, world_pos: Vector2) -> void:
	is_erasing = not tool_manager.is_erasing
	click_released()


func _mouse_movement(event: InputEvent, world_pos: Vector2) -> void:
	if editor.selected_item is PlaceableTile:
		var mouse_tile: Vector2 = get_mouse_tile_pos()
		
		var line: = line_util.get_line(last_mouse_tile, mouse_tile)

		if mouse_input == 0:
			for point in line:
				draw_tile(point)

		last_mouse_tile = mouse_tile
		
		if mouse_input == 0 and mouse_tile != last_mouse_tile:
			draw_tile(mouse_tile)
			last_mouse_tile = mouse_tile


func click() -> void:
	last_mouse_tile = get_mouse_tile_pos()
	editor.tile_buffer.modulate = shared.layer_dictionary[editor.layer].layer_tint
	draw_tile(last_mouse_tile)
	mouse_input = 0


func click_released() -> void:
	if editor.selected_item is PlaceableTile:
		if mouse_input == 0:
			finalize_placement()
			mouse_input = -1


func draw_tile(pos: Vector2) -> void:
	var item = editor.selected_item
	used_tiles.append(pos)
	undo_tiles.get_or_add(pos, shared.get_tile(pos.x, pos.y, editor.layer))
	shared.set_tile(pos.x, pos.y, editor.layer, 
		0 if is_erasing else item.tileset_id, 
		0 if is_erasing else item.tile_id, 
		0 if is_erasing else item.palette
	)


func finalize_placement() -> void:
	for tile in used_tiles:
		shared.set_tile(tile.x, tile.y, editor.layer, 0, 0, 0)

	var action := PlaceTilesAction.new()
	action.shared = shared
	action.layer = editor.layer
	action.tileset_id = 0 if is_erasing else editor.selected_item.tileset_id
	action.tile_id = 0 if is_erasing else editor.selected_item.tile_id
	action.palette = 0 if is_erasing else editor.selected_item.palette
	action.do_tiles = used_tiles
	action.undo_tiles = undo_tiles.duplicate()
	action.has_margins = shared.get_layer(editor.layer).tile_map_manager.has_margins
	editor.action_manager.commit_action(action)
	
	used_tiles.clear()
	undo_tiles.clear()


# Mouse coords to tile grid coords
func get_mouse_tile_pos() -> Vector2:
	return (get_mouse_pos() / editor.TILE_SIZE).floor()
