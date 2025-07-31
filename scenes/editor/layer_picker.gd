extends PanelContainer

onready var layer_picker = $"%LayerPicker"
onready var editor = owner

var layer_names: Array = ["BG1", "BG0", "G", "FG"]
onready var cur_layer: int = editor.layer

func pressed() -> void:
	cur_layer = wrapi(cur_layer + 1, 0, layer_names.size())
	layer_picker.text = layer_names[cur_layer]
	editor.layer = cur_layer
