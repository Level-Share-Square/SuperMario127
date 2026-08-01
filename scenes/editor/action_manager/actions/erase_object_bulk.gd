class_name EraseObjectBulkAction
extends BaseObjectAction

var objects: Array
var object_indices: Array

signal delete_undo(objects)

func _do() -> void:
	objects = objects.duplicate()
	for selected_object in objects:
		object = selected_object
		object_indices.append(object.get_index())
		if is_instance_valid(object):
			remove_object()

func _undo() -> void:
	for selected_object in objects:
		object = selected_object
		object_index = object_indices[objects.find(selected_object)]
		if is_instance_valid(object):
			restore_object()
	emit_signal("delete_undo", objects)
