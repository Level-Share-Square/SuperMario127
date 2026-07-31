class_name ObjectManager
extends Node2D


var layer_data: LayerData


func load_in(s_layer_data: LayerData):
	layer_data = s_layer_data

	for child in get_children():
		child.queue_free()
	
	for object_data in layer_data.object_data:
		create_object(object_data)

func place_object(object_data: ObjectData, add_to_data: bool = false):
	var s_position = object_data.metadata.position
	if add_to_data:
		layer_data.place_object(s_position, object_data)
	
	var game_object = create_object(object_data)
	
	return game_object


func create_object(object_data: ObjectData):
	var mode = get_tree().get_current_scene().mode
	var object_scene = CurrentLevelData.get_cached_object(object_data.metadata.type_id)
	
	var game_object = object_scene.instance()
	game_object.mode = mode
	game_object.object_data = object_data
	game_object.level_layer_ref = weakref(owner)
	game_object.palette = object_data.metadata.palette
	game_object.position = object_data.metadata.position
	
	add_child(game_object)

	
	return game_object


func erase_object(game_object) -> void:
	var object_data: ObjectData = game_object.object_data_ref
	game_object.queue_free()
	layer_data.erase_object(object_data)
