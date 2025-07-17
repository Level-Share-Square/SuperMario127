class_name PlaceObjectAction
extends BaseObjectAction


func _do() -> void:
	if is_instance_valid(object):
		restore_object()
	else:
		create_new_object()

func _undo() -> void:
	if is_instance_valid(object):
		remove_object()
