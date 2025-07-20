class_name PlaceObjectBulkAction
extends BaseObjectAction

var objects: Array = []
var new_objects: Dictionary = {}

func _do() -> void:
	print(new_objects)
	if !new_objects.empty():
		for i in new_objects:
			object = i
			object_data = i.level_object.get_ref()
			object_index = i.get_index()
			restore_object()
		return
	for i in objects:
		object_data = i
		var new_object = shared.creat_object(object_data, true)
		print(new_object)
		new_objects[new_object] = new_object.name
		

func _undo() -> void:
	for i in new_objects:
		object = i
		if is_instance_valid(i):
			remove_object()
