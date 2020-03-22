extends Node2D

class_name LevelDataLoader

export(Array, NodePath) var nodes_to_load = []

var level_data : LevelData
var level_area : LevelArea

func load_in(level_data : LevelData, level_area : LevelArea):
	self.level_data = level_data
	self.level_area = level_area
	for node_path in nodes_to_load:
		if has_node(node_path):
			var node = get_node(node_path)
			if node.has_method("load_in"):
				node.load_in(level_data, level_area)
			else:
				print("Node \"" + node.name + "\" doesn't have a load_in method")
		else:
			print("There is no node with path \"" + node_path + "\"")
