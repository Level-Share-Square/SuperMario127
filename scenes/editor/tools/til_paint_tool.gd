extends EditorTool


var last_mouse_tile: Vector2
var mouse_input: int = -1
var used_tiles: Array = []
var undo_tiles: Dictionary = {}

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
		
#		var line: = line_util.get_line(last_mouse_tile, mouse_tile)
#
#		if Input.is_action_pressed("place") and mouse_input == 0:
#			for point in line:
#				draw_tile(point)
#
#		last_mouse_tile = mouse_tile
		
		if Input.is_action_pressed("place") and mouse_input == 0 and mouse_tile != last_mouse_tile:
			draw_tile(mouse_tile)
			last_mouse_tile = mouse_tile
		
#	print(last_mouse_tile)


func draw_tile(pos: Vector2) -> void:
	var item = editor.selected_item
	used_tiles.append(pos)
	undo_tiles.get_or_add(pos, shared.get_tile(pos.x, pos.y, editor.layer))
	shared.set_tile(pos.x, pos.y, editor.layer, item.tileset_id, item.tile_id, item.palette)


func finalize_placement() -> void:
	for tile in used_tiles:
		shared.set_tile(tile.x, tile.y, editor.layer, 0, 0, 0)

	var action := PlaceTilesAction.new()
	action.shared = shared
	action.layer = editor.layer
	action.tileset_id = editor.selected_item.tileset_id
	action.tile_id = editor.selected_item.tile_id
	action.palette = editor.selected_item.palette
	action.do_tiles = used_tiles
	action.undo_tiles = undo_tiles.duplicate()
	action.has_margins = shared.get_layer(editor.layer).tile_map_manager.has_margins
	editor.action_manager.commit_action(action)
	
	used_tiles.clear()
	undo_tiles.clear()


# Mouse coords to tile grid coords
func get_mouse_tile_pos() -> Vector2:
	return (get_mouse_pos() / editor.TILE_SIZE).floor()
