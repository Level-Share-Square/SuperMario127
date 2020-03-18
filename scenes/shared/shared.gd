extends LevelDataLoader

export var tilemaps : NodePath
export var objects : NodePath

onready var tilemaps_node = get_node(tilemaps)
onready var objects_node = get_node(objects)

func set_tile(index: int, layer: int, tileset_id: int, tile_id: int):
	tilemaps_node.set_tile(index, layer, tileset_id, tile_id)

func create_object(object, add_to_data):
	objects_node.create_object(object, add_to_data)

func get_object_at_position(position):
	objects_node.get_object_at_position(position)
