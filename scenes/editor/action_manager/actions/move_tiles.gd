class_name MoveTilesAction
extends Action

var shared: LevelShared

var map_state_old: Dictionary = {}
var map_state_new: Dictionary = {}
var layer: String

var has_margins: bool
var tile_in_margin: bool = false

func move_tiles(map_state):
	tile_in_margin = false
	var tiles_dict: Dictionary = {}
	for pos in map_state:
		var tile = map_state[pos]
		shared.set_tile(pos.x, pos.y, layer, tile[0], tile[1], tile[2])
		tiles_dict.get_or_add(Vector2(pos.x, pos.y), [tile[0], tile[1], tile[2]])
	check_for_margins(tiles_dict)

func find_map_state(old_tiles, new_tiles):
	for pos in old_tiles:
		map_state_old[pos] = old_tiles[pos]
		map_state_new[pos] = [0, 0, 0]
		
	for pos in new_tiles:
		if !map_state_old.has(pos):
			map_state_old[pos] = shared.get_tile(pos.x, pos.y, layer)
		map_state_new[pos] = new_tiles[pos]

func _do() -> void:
	move_tiles(map_state_new)

func _undo() -> void:
	move_tiles(map_state_old)

func check_for_margins(tiles):
	for tile in tiles:
		if !CurrentLevelData.current_area.header.bounds.has_point(tile) and !shared.is_air(tiles[tile]): tile_in_margin = true
	
	if tile_in_margin == true and has_margins == true:
		set_margin(false)
		return
		
	if tile_in_margin == false and has_margins == false:
		set_margin(true)
		return

func set_margin(value: bool):
	var tilemap_manager = shared.get_layer(layer).tile_map_manager
	tilemap_manager._add_margins("INVALID_CELL" if !value else "LevelMargin")
	has_margins = value
	tilemap_manager.has_margins = value
