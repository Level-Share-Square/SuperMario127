class_name BaseLayerAction
extends Action

var shared: LevelShared
var layer: LevelLayer

func add_layer(layer_data: LayerData):
	if !layer_data:
		layer_data = LayerData.new(
			LayerMetadata.new(),
			TileData.new(),
			[]
		)
		layer_data.layer_metadata.order = shared.layers.back().layer_data.layer_metadata.order + 1
		layer_data.layer_metadata.layer_name = layer_data.layer_metadata.layer_name % (shared.layers.size() + 1)
	
	layer = shared.add_layer(layer_data, true)

func remove_layer():
	shared.remove_layer(shared.get_layer_index(layer), true)
