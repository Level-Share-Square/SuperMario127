class_name TileData
extends Resource


# Resource that stores tiles for any object to use and store in a level code.


const TILE_CHUNK_SIZE: int = 16

## Dictionary of Vector2s and PoolIntArrays
var chunks: Dictionary


static func get_chunk_coords(coords: Vector2) -> Vector2:
	return (coords / TILE_CHUNK_SIZE).floor()


func set_tile(coords: Vector2, tileset: int, type: int, palette: int) -> void:
	# if any of these are below 0, then the tile is being erased
	if tileset < 0 or type < 0 or palette < 0:
		tileset = 0
		type = 0
		palette = 0
	
	coords = coords.snapped(Vector2.ONE)
	var chunk_coords: Vector2 = get_chunk_coords(coords)
	var chunk: PoolIntArray = chunks.get_or_add(chunk_coords, PoolIntArray())
	if chunk.empty():
		chunk.resize(TILE_CHUNK_SIZE * TILE_CHUNK_SIZE)
		chunk.fill(0)
	
	var tile_index: int = posmod(coords.x, TILE_CHUNK_SIZE) + posmod(coords.y, TILE_CHUNK_SIZE) * TILE_CHUNK_SIZE
	chunk[tile_index] = tile_util.get_packed_tile(tileset, type, palette)
	
	chunks[chunk_coords] = chunk


func erase_tile(coords: Vector2) -> void:
	set_tile(coords, -1, -1, -1)


func get_packed_tile_at(coords: Vector2) -> int:
	return 0


func get_tile_set_id_at(coords: Vector2) -> int:
	return tile_util.get_tile_set_id_from_packed(get_packed_tile_at(coords))


func get_tile_id_at(coords: Vector2) -> int:
	return tile_util.get_tile_id_from_packed(get_packed_tile_at(coords))


func get_palette_id_at(coords: Vector2) -> int:
	return tile_util.get_palette_id_from_packed(get_packed_tile_at(coords))
