extends PanelContainer


onready var layer_picker = $"%LayerPickerOld"
onready var editor = owner
onready var shared = editor.get_shared_node()


onready var cur_layer: int = editor.layer


signal layer_changed(layer)

func _ready():
	yield(shared, "ready")
	layer_picker.text = str(shared.layers[editor.layer].order)

func pressed() -> void:
	cur_layer = wrapi(cur_layer + 1, 0, shared.layers.size())
	editor.layer = cur_layer
	layer_picker.text = str(shared.layers[editor.layer].order)
#	for tilemap in shared.tilemaps_node.get_children():
#		if editor.show_layers:
#			if tilemap.layer != editor.layer:
#				tilemap.transparent = true
#			else:
#				tilemap.transparent = false
#		else:
#			tilemap.transparent = false
	emit_signal("layer_changed", editor.layer)

