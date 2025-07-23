class_name EraseObjectBulkAction
extends BaseObjectAction

var objects: Array

func _do() -> void:
	for selected_object in objects:
		object = selected_object
		if is_instance_valid(object):
			remove_object()

func _undo() -> void:
	for selected_object in objects:
		object = selected_object
		object_index = selected_object.get_index()
		object_data = selected_object.level_object.get_ref()
		if is_instance_valid(object):
			restore_object()
