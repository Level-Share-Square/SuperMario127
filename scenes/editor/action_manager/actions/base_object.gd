class_name BaseObjectAction
extends Action


var shared: LevelShared
var layer: int
var object: GameObject
var object_data: ObjectData
var object_index: int


func create_new_object():
	object = shared.create_object(object_data, layer, true)

func remove_object():
	object_data = object.object_data_ref.get_ref()
	var objects_node: ObjectManager = shared.get_objects_manager(layer)
	objects_node.erase_object(object)
