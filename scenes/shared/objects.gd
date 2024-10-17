extends Node

#TODO: Optimize

signal finished_loading

var level_data : LevelData
var level_area : LevelArea

var object_cache = []

func load_in(loaded_level_data : LevelData, loaded_level_area : LevelArea):
	level_data = loaded_level_data
	level_area = loaded_level_area
	
	for object in loaded_level_area.objects:
		create_object(object, false)
	
	emit_signal("finished_loading")
		
func set_property(object_node : GameObject, property, value):
	object_node.set_property(property, value, true)

func create_object(object, add_to_data):
	var mode = get_tree().get_current_scene().mode
	var object_scene = Singleton.CurrentLevelData.get_cached_object(object.type_id)
	if object_scene != null:
		var object_node = object_scene.instance()
		object_node.mode = mode
		object_node.level_data = level_data
		object_node.level_area = level_area
		object_node.level_object = weakref(object)
		object_node.palette = object.palette
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
		print("Object type doesn't exist. [ID: " + str(object.type_id) + "]")
		
func get_object_at_position(position: Vector2):
	for object in self.get_children():
		if object.position == position:
			return object
			
func destroy_object(object_node, remove_from_data):
	if remove_from_data:
		var level_object = object_node.level_object.get_ref()
		level_area.objects.erase(level_object)
	object_node.queue_free()
	
func move_object_to_back(object_node):
	var level_object = object_node.level_object.get_ref()
	level_area.objects.erase(level_object)
	level_area.objects.insert(0, level_object)
	move_child(object_node, 0)
	
func move_object_to_front(object_node):
	var level_object = object_node.level_object.get_ref()
	level_area.objects.erase(level_object)
	level_area.objects.append(level_object)
	move_child(object_node, get_child_count()-1)
