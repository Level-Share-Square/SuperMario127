class_name LayerData
extends Resource


var layer_metadata: LayerMetadata
var tile_data: TileData
var object_data: Array


# Called when the node enters the scene tree for the first time.
func _init(set_layer_metadata: LayerMetadata, set_tile_data: TileData, set_object_data: Array = []):
	layer_metadata = set_layer_metadata
	object_data = set_object_data
	tile_data = set_tile_data
