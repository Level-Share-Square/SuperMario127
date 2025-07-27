extends PanelContainer

onready var layer_picker = $"%LayerPicker"
onready var editor = owner

var layer_names: Array = ["BG1", "BG0", "G", "FG"]

func _ready():
	for layer_name in layer_names:
		layer_picker.add_item(layer_name)
	layer_picker._select_int(editor.layer)
	layer_picker.connect("item_selected", self, "_on_layer_selected")
	
func _on_layer_selected(index: int) -> void:
	editor.layer = index
