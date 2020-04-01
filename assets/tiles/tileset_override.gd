tool
extends TileSet

const GRASS_BLOCK = 2
const GRASS_SLOPE_RIGHT = 4
const GRASS_SLOPE_LEFT = 5
const BRICK = 3
const BRICK_SLOPE_RIGHT = 6
const BRICK_SLOPE_LEFT = 7

var ids = [
	GRASS_BLOCK,
	GRASS_SLOPE_RIGHT,
	GRASS_SLOPE_LEFT,
	BRICK,
	BRICK_SLOPE_RIGHT,
	BRICK_SLOPE_LEFT
]

var binds = {
}

func _is_tile_bound(id, nid):
	return nid in binds[id]

func _init():
	for id in ids:
		var id_array = []
		for id2 in ids:
			if id2 != id:
				id_array.append(id2)
		binds[id] = id_array
