extends BaseLayerAction
class_name DeleteLayerAction

var layer_data: LayerData = null
var layer_index: int

func _do():
	layer = shared.get_layer_at(layer_index)
	layer_data = layer.layer_data
	remove_layer()

func _undo():
	add_layer(layer_data, layer_index)
