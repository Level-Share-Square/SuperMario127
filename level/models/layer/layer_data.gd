class_name LayerData
extends Resource





var layer_metadata: LayerMetadata
var object_data: Array


var tile_chunks: TileData


# Called when the node enters the scene tree for the first time.
func _init(set_layer_metadata: LayerMetadata, set_object_data: Array, set_tile_chunks: TileData):
	layer_metadata = set_layer_metadata
	object_data = set_object_data
	tile_chunks = set_tile_chunks
