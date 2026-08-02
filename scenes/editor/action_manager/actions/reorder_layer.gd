extends Action
class_name ReorderLayerAction

var shared: LevelShared
var layer_index: int
var final_layer_index: int

func move_layers():
	var layer_to_move: LevelLayer = shared.get_layer_at(layer_index)
	layer_to_move.layer_data.layer_metadata.order = shared.get_layer_at(final_layer_index).layer_data.layer_metadata.order
	
	shared.layers.erase(layer_to_move)
	shared.layers.insert(final_layer_index, layer_to_move)
	
	var start_pos: int = min(layer_index, final_layer_index)
	var end_pos: int = max(layer_index, final_layer_index)
	
	for i in range(start_pos, end_pos + 1):
		shared.edit_layer(shared.get_layer_at(i).layer_data.layer_metadata.layer_uuid, "order", i)

	swap_indices()

func _do():
	move_layers()
	
func _undo():
	move_layers()
	
func swap_indices():
	var old_index: int = layer_index
	layer_index = final_layer_index
	final_layer_index = old_index
