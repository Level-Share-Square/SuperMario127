class_name LayerDropdown
extends VBoxContainer


const LAYER_INFO_SCENE: PackedScene = preload("res://scenes/editor/layers/layer_info.tscn")

onready var editor: Editor = owner
onready var shared: LevelShared = editor.get_shared_node()
onready var layers: Container = $"%Layers"
onready var new_layer = $"%NewLayer"
onready var new_decor = $"%NewDecor"
onready var layer_picker = $"%LayerPicker"
onready var drag_area = $"%DragArea"
onready var origin_layer = $"%OriginLayer"
onready var mission_layer = $"%MissionLayer"
onready var layer_type = $"%LayerType"
onready var layer_name = $"%LayerName"
onready var layer_color = $"%LayerColor"

var is_dragging: bool


func _ready():
	for layer_data in shared.layers:
		add_layer(layer_data)
	shared.connect("layer_added", self, "add_layer")
	new_layer.connect("pressed", self, "new_layer", [true])
	new_decor.connect("pressed", self, "new_layer", [false])
	shared.connect("found_origin", self, "select_default")
	shared.connect("layer_type_changed", self, "update_layer_type")
	
	yield(editor, "ready")
	editor.action_manager.connect("undo", self, "check_action")
	editor.action_manager.connect("redo", self, "check_action")
	editor.action_manager.connect("action", self, "check_action")

func select_default(index: int):
	if !editor.layer and index != -1:
		select_layer(index, false)

func select_layer(index: int, toggle_dropdown: bool = true) -> void:
	var layer = shared.get_layer_at(index)
	var layer_metadata: LayerMetadata = layer.layer_data.layer_metadata
	layer_name.text = layer_metadata.layer_name
	if layer_name.text.length() > 15:
		layer_name.text = layer_name.text.left(15) + "..."
	
	layer_color.modulate = EditorLayerManager.get_band_color(
		layer_metadata.order, shared.origin.layer_data.layer_metadata.order
	)
	origin_layer.visible = layer_metadata.is_origin
	mission_layer.visible = layer_metadata.is_mission_layer()
	layer_type.modulate = LayerInfo.GROUND_COLOR if layer_metadata.is_ground else LayerInfo.PARALLAX_COLOR
	layer_type.texture = LayerInfo.GROUND_ICON if layer_metadata.is_ground else LayerInfo.PARALLAX_ICON
	
	editor.layer = shared.layer_index_to_uuid(index)
	CurrentLevelData.editor_data.selected_layer = editor.layer
	
	if toggle_dropdown:
		layer_picker.emit_signal("pressed")
		
	get_node("%ParallaxScroll")._update_parallax()
	get_node("%TileSelection").reset_bounds()
	get_node("%ObjectSelection").external_objects_selected([])


func add_layer(layer_data: LayerData) -> void:
	var layer_info: LayerInfo = LAYER_INFO_SCENE.instance()
	layer_info.shared = shared
	layer_info.load_layer(layer_data, layer_data.layer_metadata.is_origin)
	layer_info.connect("layer_selected", self, "select_layer")
	layers.add_child(layer_info)

func check_action():
	var actions: Array = [editor.action_manager.undo_stack.back(), editor.action_manager.redo_stack.back()]
	var found_action: bool = false
	for action_array in actions:
		if not action_array: continue
		for action in action_array:
			if (action is BaseLayerAction or
			action is EditLayerAction or
			action is MergeLayerAction or
			action is ReorderLayerAction):
				found_action = true
	if !found_action: return
	
	update_layers()

func update_layers() -> void:
	for layer in layers.get_children():
		layer.queue_free()
		
	for layer in shared.layers:
		var layer_data = shared.get_layer(layer).layer_data
		add_layer(layer_data)
		
	select_layer(shared.layer_uuid_to_index(editor.layer), false)


func new_layer(ground: bool = true) -> void:
	var action := AddLayerAction.new()
	action.shared = shared
	action.ground = ground
	editor.action_manager.commit_action([action])


func _process(_delta: float) -> void:
	if not is_dragging: return
	drag_area.position = get_global_mouse_position()


func layer_moved():
	var cur_layer = shared.get_layer(editor.layer)
	var cur_layer_metadata = cur_layer.layer_data.layer_metadata
	$"%LayerColor".modulate = EditorLayerManager.get_band_color(
		cur_layer_metadata.order, shared.origin.layer_data.layer_metadata.order
	)
	$"%LayerType".modulate = LayerInfo.GROUND_COLOR if cur_layer_metadata.is_ground else LayerInfo.PARALLAX_COLOR
	$"%LayerType".texture = LayerInfo.GROUND_ICON if cur_layer_metadata.is_ground else LayerInfo.PARALLAX_ICON

func _unhandled_input(event):
	if not Input.is_action_pressed("ctrl_modifier") and Input.is_action_pressed("alt_modifier"):
		var layer_index: int = shared.get_layer(editor.layer).layer_data.layer_metadata.order
		
		if event.is_action_pressed("scroll_up"):
			select_layer(wrapi(layer_index + 1, 0, shared.layers.size()), false)
			get_node("%ClickSound").play()
		if event.is_action_pressed("scroll_down"):
			select_layer(wrapi(layer_index - 1, 0, shared.layers.size()), false)
			get_node("%ClickSound").play()

func update_layer_type():
	var cur_layer = shared.get_layer(editor.layer)
	var cur_layer_metadata = cur_layer.layer_data.layer_metadata
	$"%LayerType".modulate = LayerInfo.GROUND_COLOR if cur_layer_metadata.is_ground else LayerInfo.PARALLAX_COLOR
	$"%LayerType".texture = LayerInfo.GROUND_ICON if cur_layer_metadata.is_ground else LayerInfo.PARALLAX_ICON
