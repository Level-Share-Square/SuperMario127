extends BaseLayerAction
class_name AddLayerAction

var layer_data: LayerData = null
var ground: bool = true

func _do():
	add_layer(layer_data, -1, ground)

func _undo():
	remove_layer()
