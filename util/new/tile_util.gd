class_name tile_util
extends Object


# Yummy bitpacking my favorite
# I mean this is used to pack tile data more efficiently in memory, as well as
# converting from 127's tile set ids to Godot's tile set IDs.


const TILE_CHUNK_SIZE: int = 16
const TILE_IDS: Array = preload("res://generation/tileset_ids.res").tileset_ids


static func get_packed_tile(tile_set: int, tile: int, palette: int) -> int:
	return tile_set | (tile << 16) | (palette << 32)


static func get_tile_set_id_from_packed(value: int) -> int:
	return value & 0x000000FF


static func get_tile_id_from_packed(value: int) -> int:
	return (value & 0x0000FF00) >> 16


static func get_palette_id_from_packed(value: int) -> int:
	return (value & 0x00FF0000) >> 32


static func get_real_tile_set_id_from_packed(value: int) -> int:
	return get_real_tile_set_id(
		get_tile_set_id_from_packed(value), 
		get_tile_id_from_packed(value), 
		get_palette_id_from_packed(value)
	)


static func get_real_tile_set_id(tileset_id: int, tile_id: int, palette_id: int = 0) -> int:
	if TILE_IDS[tileset_id].size() < palette_id:
		palette_id = 0
	
	return TILE_IDS[tileset_id][palette_id][tile_id]


# Takes a chunk dictionary from TileData
static func get_serialized_tiles(tile_chunks: Dictionary) -> PoolByteArray:
	return PoolByteArray()


# Returns a chunk dictionary for TileData
static func tile_bytes_to_chunks(tile_data: PoolByteArray) -> Dictionary:
	var chunks: Dictionary = {}
	var strip_start_coords: Vector2 = Vector2.ZERO
	var coords: Vector2 = Vector2.ZERO
	var next_strip: bool = true
	
	var i: int = 0
	while (i < tile_data.size()):
		if next_strip:
			next_strip = false
			strip_start_coords.x = tile_data[i] + (tile_data[i + 1] << 8)
			strip_start_coords.y = tile_data[i + 2] + (tile_data[i + 3] << 8)
			coords = strip_start_coords
			i += 4
		else:
			if tile_data[i + 1] == 0xFF:
				next_strip = true
			else:
				var chunk_coords: Vector2 = (coords / TILE_CHUNK_SIZE).floor()
				var chunk: PoolIntArray = chunks.get_or_add(chunk_coords, PoolIntArray())
				if chunk.empty():
					chunk.resize(TILE_CHUNK_SIZE * TILE_CHUNK_SIZE)
					chunk.fill(0)
				
				var tile_index: int = posmod(coords.x, TILE_CHUNK_SIZE) + posmod(coords.y, TILE_CHUNK_SIZE) * TILE_CHUNK_SIZE
				chunk[tile_index] = get_packed_tile(tile_data[i], tile_data[i + 1], tile_data[i + 2])
				
				coords.x += 1
				i += 4
	
	return chunks
