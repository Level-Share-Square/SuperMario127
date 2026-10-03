class_name BaseLayerAction
extends Action

var shared: LevelShared
var layer_uuid: String

func add_layer(layer_data: LayerData, layer_index: int = -1, ground: bool = true):
	if !layer_data:
		layer_data = LayerData.new(
			LayerMetadata.new(),
			TileData.new(),
			[]
		)
		layer_data.layer_metadata.order = shared.get_layer(shared.layers.back()).layer_data.layer_metadata.order + 1
		layer_data.layer_metadata.is_ground = ground
		layer_data.layer_metadata.autoset_tint = true
		layer_data.layer_metadata.layer_name = layer_data.layer_metadata.layer_name % (shared.layers.size() + 1)
	
	layer_index = layer_index if layer_index != -1 else shared.layers.size()
	layer_uuid = shared.add_layer(layer_data, true, layer_index).layer_data.layer_metadata.layer_uuid

func remove_layer():
	shared.remove_layer(layer_uuid, true)
