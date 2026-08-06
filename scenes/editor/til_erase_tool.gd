extends EditorTool

var last_mouse_tile: Vector2
var mouse_input: int = -1

var erased_tiles: Array = []
var undo_tiles: Dictionary = {}

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
		
#		var line: = line_util.get_line(last_mouse_tile, mouse_tile)
#
#		if Input.is_action_pressed("LMB") and mouse_input == 1:
#			for point in line:
#				erase_tile(point)
#
#		last_mouse_tile = mouse_tile
		
		if Input.is_action_pressed("LMB") and mouse_input == 1 and mouse_tile != last_mouse_tile:
			erase_tile(mouse_tile)
			last_mouse_tile = mouse_tile


func erase_tile(pos: Vector2) -> void:
	erased_tiles.append(pos)
	undo_tiles.get_or_add(pos, shared.get_tile(pos.x, pos.y, editor.layer))
	shared.set_tile(pos.x, pos.y, editor.layer, 0, 0, 0)


func finalize_erase() -> void:
	var action := PlaceTilesAction.new()
	action.shared = shared
	action.layer = editor.layer
	action.tileset_id = 0
	action.tile_id = 0
	action.palette = 0
	action.do_tiles = erased_tiles
	action.undo_tiles = undo_tiles.duplicate()
	action.has_margins = shared.get_layer(editor.layer).tile_map_manager.has_margins
	editor.action_manager.commit_action(action)
	
	erased_tiles.clear()
	undo_tiles.clear()

# Mouse coords to tile grid coords
func get_mouse_tile_pos() -> Vector2:
	return (get_mouse_pos() / editor.TILE_SIZE).floor()
	
	
