extends LevelDataLoader

export var tilemaps : NodePath
export var objects : NodePath

onready var tilemaps_node = get_node(tilemaps)
onready var objects_node = get_node(objects)

func set_tile(index: int, layer: int, tileset_id: int, tile_id: int):
	tilemaps_node.set_tile(index, layer, tileset_id, tile_id)

func create_object(object, add_to_data):
	objects_node.create_object(object, add_to_data)

func is_object_at_position(position):
	return objects_node.get_object_at_position(position)

func destroy_object_at_position(position, remove_from_data):
	var object_node = objects_node.get_object_at_position(position)
	if object_node:
		objects_node.destroy_object(object_node, remove_from_data)

func destroy_objects_overlapping_position(position, remove_from_data):
	var objectsToDelete = []
	for object_node in objects_node.get_children():
		if (object_node.position - get_global_mouse_position()).length() <= 16:
			objectsToDelete.append(object_node)	
	for object_node in objectsToDelete:
		if remove_from_data:
			level_area.objects.erase(object_node.level_object)
		object_node.queue_free()
	pass
