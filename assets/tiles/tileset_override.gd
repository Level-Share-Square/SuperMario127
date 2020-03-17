tool
extends TileSet

const GRASS_BLOCK = 2
const GRASS_SLOPE_RIGHT = 2
const GRASS_SLOPE_LEFT = 2
const BRICK = 3

var binds = {
	GRASS_BLOCK: [GRASS_SLOPE_RIGHT, GRASS_SLOPE_LEFT, BRICK],
	BRICK: [BRICK],
	GRASS_SLOPE_RIGHT: [GRASS_BLOCK, GRASS_SLOPE_LEFT, BRICK],
	GRASS_SLOPE_LEFT: [GRASS_BLOCK, GRASS_SLOPE_RIGHT, BRICK]
}

func _is_tile_bound(id, nid):
	return nid in binds[id]
