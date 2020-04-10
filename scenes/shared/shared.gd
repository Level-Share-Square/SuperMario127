extends LevelDataLoader

export var tilemaps : NodePath
export var objects : NodePath

onready var tilemaps_node = get_node(tilemaps)
onready var objects_node = get_node(objects)

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
		
func get_objects_overlapping_position(_position):
	var found_objects = []
	for object_node in objects_node.get_children():
		if (object_node.position - get_global_mouse_position()).length() <= 16:
			found_objects.append(object_node)	
	return found_objects

func destroy_objects_overlapping_position(_position, remove_from_data):
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
	
func toggle_layer_transparency(current_layer, is_transparent):
	var index = 0 
	for tilemap in tilemaps_node.get_children():
		var tilemap_color = Color(1, 1, 1, 1)
		if tilemap.name == "Back":
			tilemap_color = Color(0.54, 0.54, 0.54, 1)
		if index == current_layer:
			tilemap.modulate = tilemap_color
		else:
			if is_transparent:
				tilemap_color.a = 0.25
			tilemap.modulate = tilemap_color
		index += 1

func _process(_delta):
	OS.set_window_title("Super Mario 127 (FPS: " + str(Engine.get_frames_per_second()) + ")")
