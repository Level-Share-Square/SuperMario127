class_name PlaceTilesAction
extends Action

var shared

var do_tiles: PoolVector2Array
var layer: String
var tileset_id: int
var tile_id: int
var palette: int

var has_margins: bool
var tile_in_margin: bool = false

var undo_tiles: Dictionary = {}


class ActionTile:
	var pos: Vector2
	var lay: String
	var tileset: int
	var tile: int
	var pal: int
	
	
	func _init(position: Vector2, layer: String, tileset_id: int, tile_id: int, palette: int):
		pos = position
		lay = layer
		tileset = tileset_id
		tile = tile_id
		pal = palette


func _do() -> void:
	tile_in_margin = false
	var tile_dict: Dictionary = {}
	for tile in do_tiles:
		var last_tile = shared.get_tile(tile.x, tile.y, layer)
		
		shared.set_tile(tile.x, tile.y, layer, tileset_id, tile_id, palette)
		tile_dict.get_or_add(tile, [tileset_id, tile_id, palette])
	check_for_margins(tile_dict)

func _undo() -> void:
	tile_in_margin = false

	for tile in undo_tiles:
		shared.set_tile(
			tile.x, 
			tile.y, 
			layer, 
			undo_tiles[tile][0], 
			undo_tiles[tile][1], 
			undo_tiles[tile][2]
		)
	check_for_margins(undo_tiles)
		
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
	shared.update_tilemaps()
