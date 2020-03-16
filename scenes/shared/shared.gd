extends LevelDataLoader

export var tilemaps : NodePath

onready var tilemaps_node = get_node(tilemaps)

func set_tile(index: int, layer: int, tileset_id: int, tile_id: int):
	tilemaps_node.set_tile(index, layer, tileset_id, tile_id)
