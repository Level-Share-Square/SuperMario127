class_name PlaceTilesAction
extends Action

var shared

var do_tiles: PoolVector2Array
var layer: String
var tileset_id: int
var tile_id: int
var palette: int

var undo_tiles: Dictionary = {}

func _do() -> void:
	var tile_dict: Dictionary = {}
	for tile in do_tiles:
		var last_tile = shared.get_tile(tile.x, tile.y, layer)
		
		shared.set_tile(tile.x, tile.y, layer, tileset_id, tile_id, palette)
		tile_dict.get_or_add(tile, [tileset_id, tile_id, palette])

func _undo() -> void:
	for tile in undo_tiles:
		shared.set_tile(
			tile.x, 
			tile.y, 
			layer, 
			undo_tiles[tile][0], 
			undo_tiles[tile][1], 
			undo_tiles[tile][2]
		)
