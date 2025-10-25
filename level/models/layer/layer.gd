class_name LayerData
extends Resource


var layer_metadata: LayerMetadata
var object_datas: Array
var tile_datas: Array


# Called when the node enters the scene tree for the first time.
func _init(set_layer_metadata, set_object_datas, set_tile_datas):
	layer_metadata = set_layer_metadata
	object_datas = set_object_datas
	tile_datas = set_tile_datas
