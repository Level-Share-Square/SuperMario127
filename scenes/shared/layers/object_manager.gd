class_name ObjectManager
extends Node2D

const WATER_ID := 72 #water bug my behated
const LAVA_ID := 75
const QUICKSAND_ID := 142
var fluid_stack: Array 

var layer_data: LayerData

func load_in(s_layer_data: LayerData):
	layer_data = s_layer_data
	fluid_stack.clear()
	for child in get_children():
		child.queue_free()
	
	for object_data in layer_data.object_data:
		var obj = create_object(object_data)
		add_child(obj)
		if _is_fluid(object_data):
			fluid_stack.append(obj)
	_push_fluid_to_top()


func place_object(object_data: ObjectData, add_to_data: bool = false):
	var s_position = object_data.metadata.position
	if add_to_data:
		layer_data.place_object(s_position, object_data)
	
	var game_object = create_object(object_data)
	add_child(game_object)
	
	if _is_fluid(object_data):
		fluid_stack.append(game_object)
	move_child(game_object, get_child_count())
	_push_fluid_to_top()
	return game_object


func create_object(object_data: ObjectData):
	var mode = get_tree().get_current_scene().mode
	var object_scene
	if object_data.metadata.type_id != -1:
		object_scene = CurrentLevelData.get_cached_object(object_data.metadata.type_id)
	else:
		object_scene = load("res://scenes/actors/objects/tile_object/tile_object.tscn")
	
	var game_object = object_scene.instance()
	game_object.mode = mode
	game_object.object_data = object_data
	game_object.level_layer_ref = weakref(owner)
	game_object.palette = object_data.metadata.palette
	game_object.position = object_data.metadata.position
	return game_object


func erase_object(game_object, free: bool = true) -> void:
	if game_object in fluid_stack:
		fluid_stack.erase(game_object)
	var object_data: ObjectData = game_object.object_data
	game_object._object_removed(free)
	if free: game_object.queue_free()
	layer_data.erase_object(object_data)
	

func reorder_object(game_object, index: int) -> void:
	var max_index = get_child_count() - 1 - fluid_stack.size()
	index = clamp(index, 0, max_index)
	move_child(game_object, index)
	
	var object_data: ObjectData = game_object.object_data
	
	layer_data.object_data.erase(object_data)
	layer_data.object_data.insert(index, object_data)
	_push_fluid_to_top()

func get_absolute_z_index(target: Node2D) -> int:
	var node = target;
	var z_index = 0;
	while node and node.is_class('Node2D'):
		z_index += node.z_index;
		if !node.z_as_relative:
			break;
		node = node.get_parent();
	return z_index;


func _is_fluid(object_data: ObjectData) -> bool:
	return object_data.metadata.type_id in [WATER_ID, LAVA_ID, QUICKSAND_ID]


func _push_fluid_to_top() -> void:
	for node in fluid_stack:
		node.raise()

func refresh_object_z_index(object):
	var last_z_index = object.z_index
	object.z_index = -4096
	object.z_index = last_z_index
