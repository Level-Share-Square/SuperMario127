class_name LayerInfo
extends HBoxContainer

var layer_data: LayerData
var can_delete: bool


func load_layer(_layer_data: LayerData, _can_delete: bool, layer_color: Color) -> void:
	layer_data = _layer_data
	can_delete = _can_delete
	var layer_metadata: LayerMetadata = _layer_data.layer_metadata
	
	$"%Select".text = layer_metadata.layer_name
	$"%LayerColor".modulate = get_band_color(layer_metadata.order)

func get_band_color(order: int) -> Color:
	var max_layer: float = EditorLayerManager.MAX_LAYERS / 2.0
	var factor: float = clamp(order, -max_layer, max_layer) / max_layer
	
	return Color(
		(1 - max(0, -factor)),
		1,
		(1 - max(0, factor))
	)
