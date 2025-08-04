extends PanelContainer


onready var layer_picker = $"%LayerPicker"
onready var editor = owner
onready var shared = editor.get_node("Shared")


var layer_names: Array = ["BG0", "BG1", "G", "FG"]
onready var cur_layer: int = editor.layer


signal layer_changed(layer)


func pressed() -> void:
	cur_layer = wrapi(cur_layer + 1, 0, layer_names.size())
	layer_picker.text = layer_names[cur_layer]
	editor.layer = cur_layer
	for tilemap in shared.tilemaps_node.get_children():
		if editor.show_layers:
			if tilemap.layer != editor.layer:
				tilemap.transparent = true
			else:
				tilemap.transparent = false
		else:
			tilemap.transparent = false
	emit_signal("layer_changed", editor.layer)
