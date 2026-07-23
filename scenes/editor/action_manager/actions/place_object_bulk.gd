class_name PlaceObjectBulkAction
extends BaseObjectAction

var objects: Array = []
var new_objects: Dictionary = {}

func _do() -> void:
#	print(new_objects)
	if !new_objects.empty():
		objects = new_objects.values().duplicate(true)
		new_objects.clear()
	for i in objects:
		object_data = i
		var new_object = shared.create_object(object_data, layer, true)
		new_objects[new_object] = object_data
		

func _undo() -> void:
	for i in new_objects:
		object = i
		if is_instance_valid(i):
			remove_object()
