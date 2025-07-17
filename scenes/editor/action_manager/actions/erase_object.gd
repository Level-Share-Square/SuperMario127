class_name EraseObjectAction
extends Action


var shared: LevelShared

var object: GameObject


func _do() -> void:
	if is_instance_valid(object):
		object_data = object.level_object.get_ref()
		shared.destroy_object(object, true)


var object_data: ObjectData
func _undo() -> void:
	if is_instance_valid(object_data):
		object = shared.create_object(object_data, true)
