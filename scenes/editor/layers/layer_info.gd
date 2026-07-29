class_name LayerInfo
extends HBoxContainer

onready var edit = $"%Edit"
onready var select = $"%Select"

var shared: LevelShared
var layer_data: LayerData
var can_delete: bool

signal layer_selected(layer_index)

func _ready():
	select.connect("pressed", self, "selected")
	edit.connect("pressed", self, "test")

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

func delete_layer() -> void:
	var action := DeleteLayerAction.new()
	action.shared = shared
	action.layer_index = get_index()/2
	shared.get_parent().action_manager.commit_action(action)

func test() -> void:
	var action := ReorderLayerAction.new()
	action.shared = shared
	action.layer_index = get_index()/2
	action.final_layer_index = shared.layers.size() - 1
	shared.get_parent().action_manager.commit_action(action)
