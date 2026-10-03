extends BaseLayerAction
class_name DeleteLayerAction

var layer_data: LayerData = null
var layer_index: int

func _do():
	layer_uuid = shared.layer_index_to_uuid(layer_index)
	layer_data = shared.get_layer(layer_uuid).layer_data
	remove_layer()

func _undo():
	add_layer(layer_data, layer_index)
