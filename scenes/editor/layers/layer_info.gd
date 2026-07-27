class_name LayerInfo
extends HBoxContainer

var layer_data: LayerData
var can_delete: bool


func load_layer(_layer_data: LayerData, _can_delete: bool, layer_color: Color) -> void:
	layer_data = _layer_data
	can_delete = _can_delete
	var layer_metadata: LayerMetadata = _layer_data.layer_metadata
	
	$"%Select".text = layer_metadata.layer_name
	$"%LayerColor".modulate = layer_color
