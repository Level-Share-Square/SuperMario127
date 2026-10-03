extends Action
class_name ReorderObjectsAction

var shared
var layer_uuid: String
var objects: Array

var new_index: int
var old_indices: Array

func _do():
	var object_manager = shared.get_layer(layer_uuid).object_manager
	for object in objects:
		old_indices.append(object.get_index())
		object_manager.reorder_object(object, new_index)

func _undo():
	var pos: int = 0
	var object_manager = shared.get_layer(layer_uuid).object_manager
	for index in old_indices:
		object_manager.reorder_object(objects[pos], index)
		pos += 1
	old_indices.clear()
