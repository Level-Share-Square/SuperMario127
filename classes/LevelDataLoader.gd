extends Node2D

class_name LevelDataLoader

export(Array, NodePath) var nodes_to_load = []

var level_data : LevelData
var level_area : LevelArea

signal loaded

func load_in(loaded_level_data : LevelData, loaded_level_area : LevelArea):
	MiscShared.is_controlling = false
	level_data = loaded_level_data
	level_area = loaded_level_area
	for node_path in nodes_to_load:
		if has_node(node_path):
			var node = get_node(node_path)
			if node.has_method("load_in"):
				node.load_in(loaded_level_data, loaded_level_area)
			else:
				print("Node \"" + node.name + "\" doesn't have a load_in method")
		else:
			print("There is no node with path \"" + node_path + "\"")
	emit_signal("loaded")
