class_name tile_util

static func get_position_from_tile_index(index: int, size: Vector2) -> Vector2:
	return Vector2(
		index - (floor(index / size.x) * size.x),
		floor(index / size.x)
	)

static func get_tile_index_from_position(position: Vector2, size: Vector2) -> int:
	return int(floor((size.x * position.y) + position.x))
