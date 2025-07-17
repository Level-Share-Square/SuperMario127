class_name BaseObjectAction
extends Action


var shared: LevelShared
var object: GameObject
var object_data: ObjectData
var object_index: int


func create_new_object():
	object = shared.create_object(object_data, true)

func remove_object():
	object_data = object.level_object.get_ref()
	object_index = shared.level_area.objects.find(object_data)
	
	var objects_node: Node = shared.get_objects_node()
	objects_node.remove_child(object)
	shared.level_area.objects.erase(object_data)

func restore_object():
	var objects_node: Node = shared.get_objects_node()
	objects_node.add_child(object)
	shared.level_area.objects.insert(object_index, object_data)
