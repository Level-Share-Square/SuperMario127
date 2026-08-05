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
	undo_tiles.clear()
	tile_in_margin = false
	var tile_dict: Dictionary = {}
	for tile in do_tiles:
		var last_tile = shared.get_tile(tile.x, tile.y, layer)
		
		undo_tiles.append(
			ActionTile.new(tile, layer, last_tile[0], last_tile[1], last_tile[2])
		)
		
		shared.set_tile(tile.x, tile.y, layer, tileset_id, tile_id, palette)
		tile_dict.get_or_add(tile, [tileset_id, tile_id, palette])
	check_for_margins(tile_dict)

var undo_tiles: Array # the Z axis holds the tile id
func _undo() -> void:
	tile_in_margin = false
	var tile_positions: Dictionary = {}
	for tile in undo_tiles:
		shared.set_tile(
			tile.pos.x, 
			tile.pos.y, 
			tile.lay, 
			tile.tileset, 
			tile.tile, 
			tile.pal
		)
		tile_positions.get_or_add(Vector2(tile.pos.x, tile.pos.y), [tile.tileset, tile.tile, tile.pal])
	check_for_margins(tile_positions)
		
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
