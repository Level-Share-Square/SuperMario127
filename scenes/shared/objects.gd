extends Node

#TODO: Optimize

signal objects_ready

export(NodePath) var shared_path

var object_cache = []

var object_index: int = 0

var loaded: bool = false


func load_in():
	loaded = false
	object_index = 0
	
	
#	for object in Curre.objects:
#		print(loaded_level_area.objects.size())
#		create_object(object, false)


func set_property(object_node: GameObject, property, value):
	object_node.set_property(property, value, true)


func create_object(object, add_to_data):
	var mode = get_tree().get_current_scene().mode
	var object_scene = CurrentLevelData.get_cached_object(object.type_id)
	if object_scene != null:
		var object_node: GameObject = object_scene.instance()
		object_node.mode = mode
#		object_node.level_data = level_data
#		object_node.level_area = level_area
#		print(weakref(object))
		object_node.level_object = weakref(object)
		object_node.shared = get_node(shared_path)
		object_node.palette = object.palette
		
#		print(object_node.level_object)
		
#		if not add_to_data:
#			if object_node.layer != object_node.default_layer:
#				object_node.layer
		
		object_node._set_properties()
		
		var index = 0
		for value in object.properties:
			var true_value = old_value_util.get_true_value(value)
			object_node.set_property_by_index(index, true_value, false)
			index += 1
		
		object_node._set_property_values()
		
		call_deferred("add_child", object_node)
		
		if add_to_data:
#			level_area.objects.append(object)
			if object_node.has_method("on_place"):
				object_node.on_place()
		
		object_node.connect("ready", self, "object_ready")
		return object_node
	else:
		print("Object type doesn't exist. [ID: " + str(object.type_id) + "]")
		object_ready()


func get_object_at_position(position: Vector2):
	for object in self.get_children():
		if object.position.is_equal_approx(position):
			return object


func destroy_object(object_node, remove_from_data):
	var level_object = object_node.level_object.get_ref()
	if remove_from_data:
		pass
#		level_area.objects.erase(level_object)
#	object_node.queue_free()
#	if (!CurrentLevelData.level_info.validity_check.is_object_multiplayer_compatible(\
#	level_object.type_id,self)):
#		for area in level_data.areas:
#			for object in area.objects:
#				if (!CurrentLevelData.level_info.validity_check.is_object_multiplayer_compatible(\
#				object.type_id,self)):
#					return
#		CurrentLevelData.level_info.validity_check.is_level_multiplayer_compatible = true


func move_object_to_back(object_node):
	var level_object = object_node.level_object.get_ref()
#	level_area.objects.erase(level_object)
#	level_area.objects.insert(0, level_object)
	move_child(object_node, 0)


func move_object_to_front(object_node):
	var level_object = object_node.level_object.get_ref()
#	level_area.objects.erase(level_object)
#	level_area.objects.append(level_object)
	move_child(object_node, get_child_count()-1)


func object_ready():
	if loaded:
		return
	
	object_index += 1
#	var object_count = level_area.objects.size()
#	print("%s, %s" % [object_index, object_count])
	
#	if object_index == object_count and get_tree().get_current_scene().mode == 0:
#		loaded = true
#		emit_signal("objects_ready")
#		print("Objects are all loaded!")
