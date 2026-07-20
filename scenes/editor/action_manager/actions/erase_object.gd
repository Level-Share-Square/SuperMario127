class_name EraseObjectAction
extends BaseObjectAction


func _do() -> void:
	if is_instance_valid(object):
		remove_object()

func _undo() -> void:
	if is_instance_valid(object):
		create_new_object()
