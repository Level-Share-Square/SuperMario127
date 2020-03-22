class_name tile_util

static func get_position_from_tile_index(index: int, size: Vector2) -> Vector2:
	return Vector2(
		index - (floor(index / size.x) * size.x),
		floor(index / size.x)
	)

static func get_tile_index_from_position(position: Vector2, size: Vector2) -> int:
	return int(floor((size.x * position.y) + position.x))

static func expand_left(area, tiles):
	var new_tiles = [[0, 0]]
	var index = 1
	for tile in tiles:
		if index % int(area.settings.size.x) == 0:
			new_tiles.append([0, 0])
		new_tiles.append(tile)
		index += 1
	return new_tiles

static func shrink_left(area, tiles):
	var new_tiles = []
	var index = 0
	for tile in tiles:
		if index % int(area.settings.size.x) != 0 and index != 0:
			new_tiles.append(tile)
		index += 1
	return new_tiles

static func expand_right(area, tiles):
	var new_tiles = []
	var index = 1
	for tile in tiles:
		new_tiles.append(tile)
		if index % int(area.settings.size.x) == 0 and index != 0 and index != tiles.size():
			new_tiles.append([0, 0])
		index += 1
	return new_tiles

static func shrink_right(area, tiles):
	var new_tiles = []
	var index = 1
	for tile in tiles:
		if index % int(area.settings.size.x) != 0 and index != 0:
			new_tiles.append(tile)
		index += 1
	return new_tiles

static func expand_down(area, tiles):
	var new_tiles = []
	for tile in tiles:
		new_tiles.append(tile)
	for index in range(area.settings.size.x):
		new_tiles.append([0, 0])
	return new_tiles

static func shrink_down(area, tiles):
	var new_tiles = []
	for tile in tiles:
		new_tiles.append(tile)
	for index in range(area.settings.size.x):
		new_tiles.pop_back()
	return new_tiles

static func expand_up(area, tiles):
	var new_tiles = []
	for index in range(area.settings.size.x):
		new_tiles.append([0, 0])
	for tile in tiles:
		new_tiles.append(tile)
	return new_tiles

static func shrink_up(area, tiles):
	var new_tiles = []
	for tile in tiles:
		new_tiles.append(tile)
	for index in range(area.settings.size.x):
		new_tiles.pop_front()
	return new_tiles
