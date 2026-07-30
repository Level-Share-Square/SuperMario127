extends EditorWindow

onready var layer_properties = $"%LayerProperties"

var layer_index: int
var layer_data: LayerData

func populate_window(data: LayerData) -> void:
	layer_data = data
	layer_index = data.layer_metadata.order
	layer_properties.layer_data = layer_data
	layer_properties.load_base_properties()
	toggle_window()
