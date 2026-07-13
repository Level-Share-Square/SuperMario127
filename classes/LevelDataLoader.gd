class_name LevelDataLoader
extends Node2D


export(Array, NodePath) var nodes_to_load = []


signal loaded


func load_in():
	Singleton.MiscShared.is_controlling = false
	for node_path in nodes_to_load:
		if has_node(node_path):
			var node = get_node(node_path)
			if node.has_method("load_in"):
				node.load_in()
			else:
				print("Node \"" + node.name + "\" doesn't have a load_in method")
		else:
			print("There is no node with path \"" + node_path + "\"")
	emit_signal("loaded")
