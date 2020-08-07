extends Node

#TODO: Optimize

var level_data : LevelData
var level_area : LevelArea

var object_cache = []

func load_in(loaded_level_data : LevelData, loaded_level_area : LevelArea):
	level_data = loaded_level_data
	level_area = loaded_level_area
	
	CurrentLevelData.level_data.vars.max_red_coins = 0
	CurrentLevelData.level_data.vars.red_coins_collected = 0
	CurrentLevelData.enemies_instanced = 0
	CurrentLevelData.level_data.vars.doors = []
	for object in loaded_level_area.objects:
		create_object(object, false)
		
func set_property(object_node : GameObject, property, value):
	object_node.set_property(property, value, true)

func create_object(object, add_to_data):
	var mode = get_tree().get_current_scene().mode
	var object_scene = CurrentLevelData.object_cache[object.type_id]
	if object_scene != null:
		var object_node = object_scene.instance()
		object_node.mode = mode
		object_node.level_data = level_data
		object_node.level_area = level_area
		object_node.level_object = weakref(object)
		#object_node._init_signals() - Disabled because it's not needed atm
		object_node._set_properties()
		var index = 0
		for value in object.properties:
			var true_value = value_util.get_true_value(value)
			object_node.set_property_by_index(index, true_value, false)
			index += 1
		object_node._set_property_values()
		call_deferred("add_child", object_node)
		if add_to_data:
			level_area.objects.append(object)
			if object_node.has_method("on_place"):
				object_node.on_place()
		return object_node
	else:
		print("Object type doesn't exist.")
		
func get_object_at_position(position: Vector2):
	for object in self.get_children():
		if object.position == position:
			return object
			
func destroy_object(object_node, remove_from_data):
	if remove_from_data:
		var level_object = object_node.level_object.get_ref()
		level_area.objects.erase(level_object)
	object_node.queue_free()
