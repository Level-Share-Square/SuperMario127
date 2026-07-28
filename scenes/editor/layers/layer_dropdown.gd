extends VBoxContainer


const LAYER_INFO_SCENE: PackedScene = preload("res://scenes/editor/layers/layer_info.tscn")

onready var editor: Editor = owner
onready var shared: LevelShared = editor.get_shared_node()
onready var layers: Container = $"%Layers"
onready var new_layer = $"%NewLayer"


func _ready():
	for layer_data in shared.layers:
		add_layer(layer_data)
	shared.connect("layer_added", self, "add_layer")
	new_layer.connect("button_down", self, "new_layer")
	
	yield(editor, "ready")
	editor.action_manager.connect("undo", self, "update_layers")
	editor.action_manager.connect("redo", self, "update_layers")
	editor.action_manager.connect("action", self, "update_layers")

func add_layer(layer_data: LayerData) -> void:	
	var layer_info: LayerInfo = LAYER_INFO_SCENE.instance()
	layer_info.load_layer(layer_data, layer_data.layer_metadata.order == editor.layer, Color.red)
	layer_info.shared = shared
	layers.add_child(layer_info)

	var h_separator := HSeparator.new()
	layers.add_child(h_separator)

func update_layers() -> void:
	for layer in layers.get_children():
		layer.queue_free()
		
	for layer in shared.layers:
		var layer_data = layer.layer_data
		
		var layer_info: LayerInfo = LAYER_INFO_SCENE.instance()
		layer_info.load_layer(layer_data, layer_data.layer_metadata.order == editor.layer, Color.red)
		layer_info.shared = shared
		layers.add_child(layer_info)

		var h_separator := HSeparator.new()
		layers.add_child(h_separator)

func new_layer() -> void:
	var action := AddLayerAction.new()
	action.shared = shared
	editor.action_manager.commit_action(action)
