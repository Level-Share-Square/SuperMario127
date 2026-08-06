class_name PlaceObjectBulkAction
extends BaseObjectAction

var objects: Array = []
var new_objects: Dictionary = {}

func _do() -> void:
	if !new_objects.empty():
		for new_object in new_objects:
			object = new_object
			object_index = new_objects[new_object]
			restore_object()
		return
	for i in objects:
		object_data = i
		var new_object = shared.create_object(object_data, layer, true)
		new_objects[new_object] = new_object.get_index()
		

func _undo() -> void:
	for i in new_objects:
		object = i
		if is_instance_valid(i):
			remove_object()
