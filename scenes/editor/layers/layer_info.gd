class_name LayerInfo
extends HBoxContainer

onready var edit = $"%Edit"
onready var select = $"%Select"

var shared: LevelShared
var layer_data: LayerData
var can_delete: bool

signal layer_selected(layer_data)

func _ready():
	select.connect("pressed", self, "emit_signal", ["layer_selected", layer_data.layer_metadata.order])

func load_layer(_layer_data: LayerData, _can_delete: bool) -> void:
	layer_data = _layer_data
	can_delete = _can_delete
	var layer_metadata: LayerMetadata = _layer_data.layer_metadata
	
	$"%Select".text = layer_metadata.layer_name
	$"%LayerColor".modulate = EditorLayerManager.get_band_color(layer_metadata.order, 2)

func delete_layer() -> void:
	var action := DeleteLayerAction.new()
	action.shared = shared
	action.layer_index = get_index()/2
	shared.get_parent().action_manager.commit_action(action)

func test() -> void:
	var action := EditLayerAction.new()
	action.shared = shared
	action.property = "layer_tint"
	action.new_value = Color.blue
	action.layer_index = get_index()/2
	shared.get_parent().action_manager.commit_action(action)
