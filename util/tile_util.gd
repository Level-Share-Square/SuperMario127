class_name tile_util

onready var tileset_cache := TilesetCache.new()

static func get_position_from_tile_index(index: int, size: Vector2) -> Vector2:
	return Vector2(
		index - (floor(index / size.x) * size.x),
		floor(index / size.x)
	)

static func get_tile_index_from_position(position: Vector2, size: Vector2) -> int:
	return int(floor((size.x * position.y) + position.x))
	
static func get_tile(tileset_id, tile_id):
	var tileset = tileset_cache.cache[tileset_id]
	if tile_id == 0:
		return tileset.block_tile_id
	elif tile_id == 1:
		return tileset.slab_tile_id
	elif tile_id == 2:
		return tileset.left_slope_tile_id
	else:
		return tileset.right_slope_tile_id

static func place_edges(pos, placing_tile, bounds, tilemap_node):
	if pos.x == 0:
		tilemap_node.set_cell(-1, pos.y, placing_tile)
	if pos.y == 0:
		tilemap_node.set_cell(pos.x, -1, placing_tile)
	if pos.x == 0 && pos.y == 0:
		tilemap_node.set_cell(-1, -1, placing_tile)
	if pos.x == 0 && pos.y == bounds.y - 1:
		tilemap_node.set_cell(-1, bounds.y, placing_tile)
		
	if pos.x == bounds.x - 1:
		tilemap_node.set_cell(bounds.x, pos.y, placing_tile)
	if pos.y == bounds.y - 1:
		tilemap_node.set_cell(pos.x, bounds.y, placing_tile)
	if pos.x == bounds.x - 1 && pos.y == bounds.y - 1:
		tilemap_node.set_cell(bounds.x, bounds.y, placing_tile)
	if pos.x == bounds.x - 1 && pos.y == 0:
		tilemap_node.set_cell(bounds.x, -1, placing_tile)
