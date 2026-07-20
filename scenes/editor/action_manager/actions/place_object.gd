class_name PlaceObjectAction
extends BaseObjectAction


func _do() -> void:
	create_new_object()

func _undo() -> void:
	if is_instance_valid(object):
		remove_object()
