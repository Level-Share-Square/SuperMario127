extends Action
class_name ReorderLayerAction

var shared: LevelShared
var layer_index: int
var final_layer_index: int

func move_layers():
	var layer_to_move: LevelLayer = shared.get_layer_at(layer_index)
	var layer_uuid: String = shared.layer_index_to_uuid(layer_index)
	
	shared.layers.erase(layer_uuid)
	shared.layers.insert(final_layer_index, layer_uuid)
	
	shared.move_layer(layer_to_move, final_layer_index, true)

	swap_indices()

func _do():
	move_layers()
	
func _undo():
	move_layers()
	
func swap_indices():
	var old_index: int = layer_index
	layer_index = final_layer_index
	final_layer_index = old_index
