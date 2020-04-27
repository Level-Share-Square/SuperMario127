tool
extends TileSet

const GRASS_BLOCK = 2
const GRASS_SLOPE_RIGHT = 4
const GRASS_SLOPE_LEFT = 5
const GRASS_SLAB = 8

const BRICK = 3
const BRICK_SLOPE_RIGHT = 6
const BRICK_SLOPE_LEFT = 7

const GREEN_BRICK = 9
const GREEN_BRICK_SLOPE_RIGHT = 10
const GREEN_BRICK_SLOPE_LEFT = 11

const RED_BRICK = 12
const RED_BRICK_SLOPE_RIGHT = 13
const RED_BRICK_SLOPE_LEFT = 14

const YELLOW_BRICK = 15
const YELLOW_BRICK_SLOPE_RIGHT = 16
const YELLOW_BRICK_SLOPE_LEFT = 17

const BOO_BLOCK = 18

var ids = [
	GRASS_BLOCK,
	GRASS_SLOPE_RIGHT,
	GRASS_SLOPE_LEFT,
	GRASS_SLAB,
	
	BRICK,
	BRICK_SLOPE_RIGHT,
	BRICK_SLOPE_LEFT,
	
	GREEN_BRICK,
	GREEN_BRICK_SLOPE_RIGHT,
	GREEN_BRICK_SLOPE_LEFT,
	
	RED_BRICK,
	RED_BRICK_SLOPE_RIGHT,
	RED_BRICK_SLOPE_LEFT,
	
	YELLOW_BRICK,
	YELLOW_BRICK_SLOPE_RIGHT,
	YELLOW_BRICK_SLOPE_LEFT,
	
	BOO_BLOCK
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
