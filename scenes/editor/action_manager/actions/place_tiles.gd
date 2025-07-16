class_name PlaceTilesAction
extends Action

var shared: LevelShared

var do_tiles: PoolVector2Array
var layer: int
var tileset_id: int
var tile_id: int
var palette: int


class Tile:
	var pos: Vector2
	var lay: int
	var tileset: int
	var tile: int
	var pal: int
	
	
	func _init(position: Vector2, layer: int, tileset_id: int, tile_id: int, palette: int):
		pos = position
		lay = layer
		tileset = tileset_id
		tile = tile_id
		pal = palette


func _do() -> void:
	undo_tiles.clear()
	for tile in do_tiles:
		undo_tiles.append(
			Tile.new(tile, layer, tileset_id, tile_id, palette)
		)
		
		shared.set_tile(tile.x, tile.y, layer, tileset_id, tile_id, palette)


var undo_tiles: Array # the Z axis holds the tile id
func _undo() -> void:
	for tile in undo_tiles:
		shared.set_tile(
			tile.pos.x, 
			tile.pos.y, 
			tile.lay, 
			0, 
			0, 
			0
		)
