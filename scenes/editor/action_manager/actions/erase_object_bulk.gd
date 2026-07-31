class_name EraseObjectBulkAction
extends BaseObjectAction

var objects: Array
var object_datas: Array

signal delete_undo(objects)

func _do() -> void:
	for selected_object in objects:
		object = selected_object
		object_datas.append(object.object_data_ref.get_ref())
		if is_instance_valid(object):
			remove_object()

func _undo() -> void:
	objects.clear()
	for data in object_datas:
		object_data = data
		create_new_object()
		objects.append(object)
	emit_signal("delete_undo", objects)
