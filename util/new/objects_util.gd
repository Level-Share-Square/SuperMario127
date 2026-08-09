extends Node
class_name objects_util

static func object_data_deep_copy(game_object):
	var object_data = game_object.object_data
	var copied_metadata := ObjectMetadata.new(object_data.metadata.position, object_data.metadata.type_id, object_data.metadata.palette)
	var properties: Dictionary = object_data.properties.duplicate(true)
	
	for property in properties.keys():
		if game_object.property_ids[property] in game_object.property_defaults.keys(): continue
		if !game_object.property_ids[property] in game_object.editable_properties:
			properties.erase(property)
	var copied_data := ObjectData.new(copied_metadata, properties)
	return copied_data

static func find_closest_object(objects: Array, mouse_pos: Vector2):
	var closest_object = objects[0]
	var min_dist: float = INF
	
	for object in objects:
		var dist: float = mouse_pos.distance_squared_to(object.global_position)
		
		if dist < min_dist:
			closest_object = object
			min_dist = dist

	return closest_object
