extends BaseLayerAction
class_name AddLayerAction

var layer_data: LayerData = null
var ground: bool = true
var insert_index: int = -1

func _do():
	add_layer(layer_data, insert_index, ground)

func _undo():
	remove_layer()
