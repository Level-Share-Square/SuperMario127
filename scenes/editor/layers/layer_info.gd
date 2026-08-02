class_name LayerInfo
extends HBoxContainer

onready var edit = $"%Edit"
onready var select = $"%Select"
onready var show_hide = $"%ShowHide"

onready var eye_open = preload("res://scenes/editor/assets/EyeOpen.svg")
onready var eye_closed = preload("res://scenes/editor/assets/EyeClosed.svg")

var shared: LevelShared
var layer_data: LayerData
var can_delete: bool

signal layer_selected(layer_index)

func _ready():
	select.connect("pressed", self, "selected")
	edit.connect("pressed", self, "show_layer_editor")
	show_hide.connect("pressed", self, "toggle_visibility")

func selected():
	emit_signal("layer_selected", layer_data.layer_metadata.order)

func load_layer(_layer_data: LayerData, _can_delete: bool) -> void:
	layer_data = _layer_data
	can_delete = _can_delete
	var layer_metadata: LayerMetadata = _layer_data.layer_metadata
	
	$"%Select".text = layer_metadata.layer_name
	
	if !is_instance_valid(shared.origin):
		yield(shared, "found_origin")
	
	$"%LayerColor".modulate = EditorLayerManager.get_band_color(layer_metadata.order, shared.origin.layer_data.layer_metadata.order)
	
	if !is_node_ready():
		yield(self, "ready")
	
	show_hide.icon = eye_open if layer_metadata.layer_visible else eye_closed
	
func delete_layer() -> void:
	var action := DeleteLayerAction.new()
	action.shared = shared
	action.layer_index = layer_data.layer_metadata.order
	shared.get_parent().action_manager.commit_action(action)

func show_layer_editor() -> void:
	var layer_editor = shared.get_node("%LayerEditor")
	layer_editor.populate_window(layer_data)

func toggle_visibility() -> void:
	var action := EditLayerAction.new()
	action.layer_index = layer_data.layer_metadata.order
	action.shared = shared
	action.property = "layer_visible"
	action.new_value = !layer_data.layer_metadata.layer_visible
	shared.get_parent().action_manager.commit_action(action)

	layer_data = shared.get_layer_at(layer_data.layer_metadata.order).layer_data
	show_hide.icon = eye_open if layer_data.layer_metadata.layer_visible else eye_closed
