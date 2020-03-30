extends LevelDataLoader

export var tilemaps : NodePath
export var objects : NodePath
export var background : NodePath

onready var tilemaps_node = get_node(tilemaps)
onready var objects_node = get_node(objects)
onready var background_node = get_node(background)

func get_objects_node():
	return objects_node

func set_tile(index: int, layer: int, tileset_id: int, tile_id: int):
	tilemaps_node.set_tile(index, layer, tileset_id, tile_id)

func create_object(object, add_to_data):
	return objects_node.create_object(object, add_to_data)
	
func destroy_object(object, remove_from_data):
	objects_node.destroy_object(object, remove_from_data)

func is_object_at_position(position):
	return objects_node.get_object_at_position(position)

func destroy_object_at_position(position, remove_from_data):
	var object_node = objects_node.get_object_at_position(position)
	if object_node:
		objects_node.destroy_object(object_node, remove_from_data)
		
func get_objects_overlapping_position(position):
	var objects = []
	for object_node in objects_node.get_children():
		if (object_node.position - get_global_mouse_position()).length() <= 16:
			objects.append(object_node)	
	return objects

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
	
func move_all_objects_by(offset):
	for object_node in objects_node.get_children():
		object_node.position += offset
		object_node.level_object.properties[0] += offset
		if object_node.position.x < -32 or object_node.position.x > (CurrentLevelData.level_data.areas[0].settings.size.x * 32) + 32 or object_node.position.y < -32 or object_node.position.y > (CurrentLevelData.level_data.areas[0].settings.size.y * 32) + 32:
			level_area.objects.erase(object_node.level_object)
			object_node.queue_free()
		
func update_tilemaps():
	tilemaps_node.update_tilemaps()

func update_background(area):
	pass #background_node.update_background(area)

func _process(delta):
	OS.set_window_title("Super Mario 127 (FPS: " + str(Engine.get_frames_per_second()) + ")")
