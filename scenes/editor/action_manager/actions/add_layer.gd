extends BaseLayerAction
class_name AddLayerAction

var layer_data: LayerData = null

func _do():
	add_layer(layer_data)

func _undo():
	remove_layer()
