class_name tile_util
extends Object


# Yummy bitpacking my favorite
# I mean this is used to pack tile data more efficiently in memory, as well as
# converting from 127's tile set ids to Godot's tile set IDs.


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
static func deserialize_tiles_into_chunks(tile_data: PoolByteArray) -> Dictionary:
	return {}
