class_name PlaceTilesAction
extends Action

var shared: LevelShared

var do_tiles: PoolVector2Array
var layer: int
var tileset_id: int
var tile_id: int
var palette: int


class ActionTile:
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
		var last_tile = shared.get_tile(tile.x, tile.y, layer)
		
		undo_tiles.append(
			ActionTile.new(tile, layer, last_tile[0], last_tile[1], last_tile[2])
		)
		
		shared.set_tile(tile.x, tile.y, layer, tileset_id, tile_id, palette)


var undo_tiles: Array # the Z axis holds the tile id
func _undo() -> void:
	for tile in undo_tiles:
		shared.set_tile(
			tile.pos.x, 
			tile.pos.y, 
			tile.lay, 
			tile.tileset, 
			tile.tile, 
			tile.pal
		)
