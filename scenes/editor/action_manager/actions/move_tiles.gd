class_name MoveTilesAction
extends Action

var shared: LevelShared

var old_tiles: Dictionary
var new_tiles: Dictionary
var layer: int


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
	
	var tile_types: Array
	for tile in new_tiles.values():
		if !tile in tile_types && !tile == [0, 0, 0]:
			tile_types.append(tile)
			
	if !old_tiles.empty():
		for tile in old_tiles.keys():
			var last_tile = shared.get_tile(tile.x, tile.y, layer)
			
			undo_tiles.append(
				ActionTile.new(tile, layer, last_tile[0], last_tile[1], last_tile[2])
			)
			
			shared.set_tile(tile.x, tile.y, layer, 0, 0, 0)

		for tile in old_tiles:
				var tileset_id = old_tiles[tile][0]
				var tile_id = old_tiles[tile][1]
				var palette = old_tiles[tile][2]
				
				undo_tiles.append(
					ActionTile.new(tile, layer, tileset_id, tile_id, palette)
				)
		
	for tile_value in tile_types:
		for tile in new_tiles:
			if new_tiles[tile] == tile_value:
				var tileset_id = tile_value[0]
				var tile_id = tile_value[1]
				var palette = tile_value[2]
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
