extends VBoxContainer


const LAYER_INFO_SCENE: PackedScene = preload("res://scenes/editor/layers/layer_info.tscn")

onready var editor: Editor = owner
onready var shared: LevelShared = editor.get_shared_node()
onready var layers: Container = $"%Layers"


func _ready():
	for layer_data in shared.layers:
		add_layer(layer_data)
	shared.connect("layer_added", self, "add_layer")


func add_layer(layer_data: LayerData) -> void:
	# layer color should probably be based on its order 
	# relative to all other layers, but not sure how to do this yet...
	
	var layer_info: LayerInfo = LAYER_INFO_SCENE.instance()
	layer_info.load_layer(layer_data, layer_data.layer_metadata.order == editor.layer, Color.red)
	layers.add_child(layer_info)

	var h_separator := HSeparator.new()
	layers.add_child(h_separator)
