class_name BaseObjectAction
extends Action


var shared: LevelShared
var layer: int
var object: GameObject
var object_data: ObjectData
var object_index: int


func create_new_object():
	object = shared.create_object(object_data, layer)

func remove_object():
	var objects_node: Node = shared.get_objects_manager(layer)
	
	object_data = object.object_data_ref.get_ref()
	object_index = objects_node.find(object_data)

	objects_node.remove_child(object)

func restore_object():
	var objects_node: Node = shared.get_objects_manager(layer)
	objects_node.add_child(object)
