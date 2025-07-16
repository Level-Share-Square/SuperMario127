class_name PlaceObjectAction
extends Action


var shared: LevelShared

var object_data: ObjectData


func _do() -> void:
	object = shared.create_object(object_data, true)


var object: GameObject
func _undo() -> void:
	shared.destroy_object(object, true)
