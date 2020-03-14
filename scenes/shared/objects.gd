extends Node

var object_id_map : IdMap = load("res://scenes/actors/objects/ids.tres")

func load_in(level_data : LevelData, level_area : LevelArea):
	var mode = get_tree().get_current_scene().mode
	for object in level_area.objects:
		var object_name = object_id_map.ids[object.type_id - 1] # thanks maker
		var object_scene = load("res://scenes/actors/objects/" + object_name + "/" + object_name + ".tscn")
		if object_scene != null:
			var object_node = object_scene.instance()
			object_node.mode = mode
			for key in object.properties:
				var value = object.properties[key]
				var true_value = value_util.get_true_value(value)
				object_node[key] = true_value
			add_child(object_node)
		else:
			print("Object type " + object_name + " doesn't exist.")
