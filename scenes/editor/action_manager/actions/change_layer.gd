extends Action
class_name ChangeLayerAction

var layer_uuid: String
var shared

func _do():
	shared.change_layer_type(shared.get_layer(layer_uuid))

func _undo():
	shared.change_layer_type(shared.get_layer(layer_uuid))
