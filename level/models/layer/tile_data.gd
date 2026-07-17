class_name TileData
extends Resource


# Resource that stores tiles for any object to use and store in a level code.


const TILE_CHUNK_SIZE: int = 16

## Dictionary of Vector2s and PoolIntArrays
var chunks: Dictionary = {}
var used_tiles: PoolVector2Array = PoolVector2Array()


func _init() -> void:
	chunks = {}
	used_tiles = PoolVector2Array()


static func get_chunk_coords(coords: Vector2) -> Vector2:
	return (coords / TILE_CHUNK_SIZE).floor()


func set_tile(coords: Vector2, tileset: int, type: int, palette: int) -> void:
	# if any of these are below 0, then the tile is being erased
	if tileset <= 0 or type <= 0 or palette <= 0:
		tileset = 0
		type = 0
		palette = 0
		
		while used_tiles.has(coords):
			used_tiles.remove(used_tiles.find(coords))
	else:
		if not used_tiles.has(coords):
			used_tiles.append(coords)
	
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


func set_chunk_data(chunk_coords: Vector2, chunk_data: PoolIntArray) -> void:
	if chunk_data.count(0) >= tile_util.TILE_CHUNK_SIZE * tile_util.TILE_CHUNK_SIZE:
		return
	
	if chunks.has(chunk_coords):
		chunks[chunk_coords] = chunk_data
	else:
		chunks.get_or_add(chunk_coords, chunk_data)
	
	for x in range(tile_util.TILE_CHUNK_SIZE):
		for y in range(tile_util.TILE_CHUNK_SIZE):
			if chunk_data[x + y * TILE_CHUNK_SIZE] > 0:
				used_tiles.append(chunk_coords * 16 + Vector2(x, y))


func get_packed_tile_at(coords: Vector2) -> int:
	var chunk_coords: Vector2 = get_chunk_coords(coords)
	var chunk: PoolIntArray = chunks.get(chunk_coords, PoolIntArray())
	if chunk.empty():
		chunk.resize(TILE_CHUNK_SIZE * TILE_CHUNK_SIZE)
		chunk.fill(0)
	
	var tile_index: int = posmod(coords.x, TILE_CHUNK_SIZE) + posmod(coords.y, TILE_CHUNK_SIZE) * TILE_CHUNK_SIZE
	return chunk[tile_index]


func get_tile_set_id_at(coords: Vector2) -> int:
	return tile_util.get_tile_set_id_from_packed(get_packed_tile_at(coords))


func get_tile_id_at(coords: Vector2) -> int:
	return tile_util.get_tile_id_from_packed(get_packed_tile_at(coords))


func get_palette_id_at(coords: Vector2) -> int:
	return tile_util.get_palette_id_from_packed(get_packed_tile_at(coords))
