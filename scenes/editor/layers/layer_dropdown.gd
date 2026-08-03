class_name LayerDropdown
extends VBoxContainer


const LAYER_INFO_SCENE: PackedScene = preload("res://scenes/editor/layers/layer_info.tscn")

onready var editor: Editor = owner
onready var shared: LevelShared = editor.get_shared_node()
onready var layers: Container = $"%Layers"
onready var new_layer = $"%NewLayer"
onready var new_decor = $"%NewDecor"
onready var layer_picker = $"%LayerPicker"
onready var parallax_scroll = $"%ParallaxScroll"
onready var drag_area = $"%DragArea"

var is_dragging: bool


func _ready():
	for layer_data in shared.layers:
		add_layer(layer_data)
	shared.connect("layer_added", self, "add_layer")
	new_layer.connect("button_down", self, "new_layer", [true])
	new_decor.connect("button_down", self, "new_layer", [false])
	shared.connect("found_origin", self, "select_layer", [false])
	
	yield(editor, "ready")
	editor.action_manager.connect("undo", self, "update_layers")
	editor.action_manager.connect("redo", self, "update_layers")
	editor.action_manager.connect("action", self, "update_layers")


func select_layer(index: int, toggle_dropdown: bool = true) -> void:
	var layer = shared.get_layer_at(index)
	var layer_metadata: LayerMetadata = layer.layer_data.layer_metadata
	layer_picker.text = layer_metadata.layer_name
	
	layer_picker.get_node("LayerColor").modulate = EditorLayerManager.get_band_color(
		layer_metadata.order, shared.origin.layer_data.layer_metadata.order
	)
	editor.layer = shared.layer_index_to_uuid(index)
	
	if toggle_dropdown:
		layer_picker.emit_signal("pressed")


func add_layer(layer_data: LayerData) -> void:
	var layer_info: LayerInfo = LAYER_INFO_SCENE.instance()
	layer_info.shared = shared
	layer_info.load_layer(layer_data, layer_data.layer_metadata.is_origin)
	layer_info.connect("layer_selected", self, "select_layer")
	layers.add_child(layer_info)


func update_layers() -> void:
	for layer in layers.get_children():
		layer.queue_free()
		
	for layer in shared.layers:
		var layer_data = shared.get_layer(layer).layer_data
		add_layer(layer_data)


func new_layer(ground: bool = true) -> void:
	var action := AddLayerAction.new()
	action.shared = shared
	action.ground = ground
	editor.action_manager.commit_action(action)


func _process(_delta: float) -> void:
	if not is_dragging: return
	drag_area.position = get_global_mouse_position()


func layer_moved():
	var cur_layer_metadata = shared.get_layer(editor.layer)
	layer_picker.get_node("LayerColor").modulate = EditorLayerManager.get_band_color(
		cur_layer_metadata.order, shared.origin.layer_data.layer_metadata.order
	)
