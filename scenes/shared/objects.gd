extends Node

var level_data : LevelData
var level_area : LevelArea

var object_id_map : IdMap = load("res://scenes/actors/objects/ids.tres")

func load_in(level_data : LevelData, level_area : LevelArea):
	self.level_data = level_data
	self.level_area = level_area
	
	var mode = get_tree().get_current_scene().mode
	for object in level_area.objects:
		create_object(object, false)

func create_object(object, add_to_data):
	print_debug("a")
	var mode = get_tree().get_current_scene().mode
	var object_name = object_id_map.ids[object.type_id] # ok boomer
	var object_scene = load("res://scenes/actors/objects/" + object_name + "/" + object_name + ".tscn")
	if object_scene != null:
		var object_node = object_scene.instance()
		object_node.mode = mode
		for key in object.properties:
			var value = object.properties[key]
			var true_value = value_util.get_true_value(value)
			object_node[key] = true_value
		add_child(object_node)
		if add_to_data:
			level_area.objects.append(object)
	else:
		print("Object type " + object_name + " doesn't exist.")
