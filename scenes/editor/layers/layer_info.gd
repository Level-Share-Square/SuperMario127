class_name LayerInfo
extends VBoxContainer

onready var layer_dropdown = get_parent().get_node("%LayerDropdown")

onready var panel_container = $"%PanelContainer"
onready var collision_shape = $"%CollisionShape2D"
onready var edit = $"%Edit"
onready var select = $"%Select"
onready var show_hide = $"%ShowHide"
onready var delete = $"%Delete"

onready var hover_sound = $"%HoverSound"
onready var click_sound = $"%ClickSound"

onready var eye_open = preload("res://assets/icons/EyeOpen.svg")
onready var eye_closed = preload("res://assets/icons/EyeClosed.svg")

var shared: LevelShared
var layer_data: LayerData
var can_delete: bool

var is_dragging: bool

signal layer_selected(layer_index)


func _ready():
	select.connect("pressed", self, "selected")
	edit.connect("pressed", self, "show_layer_editor")
	show_hide.connect("pressed", self, "toggle_visibility")
	panel_resized()


func selected():
	emit_signal("layer_selected", layer_data.layer_metadata.order)
	shared.focus_layer(shared.get_parent().focus_layer, layer_data.layer_metadata.layer_uuid)


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
	
	delete.disabled = can_delete

func delete_layer() -> void:
	var editor = layer_dropdown.editor
	if(layer_data.layer_metadata.layer_uuid == editor.layer):
		emit_signal("layer_selected", shared.origin.layer_data.layer_metadata.order)
		shared.focus_layer(shared.get_parent().focus_layer, shared.origin.layer_data.layer_metadata.layer_uuid)
	var action := DeleteLayerAction.new()
	action.shared = shared
	action.layer_index = layer_data.layer_metadata.order
	shared.get_parent().action_manager.commit_action(action)


func show_layer_editor() -> void:
	var layer_editor = shared.get_node("%LayerEditor")
	layer_editor.populate_window(layer_data)


func toggle_visibility() -> void:
	if shared.get_parent().focus_layer: return
	var action := EditLayerAction.new()
	action.layer_index = layer_data.layer_metadata.order
	action.shared = shared
	action.property = "layer_visible"
	action.new_value = !layer_data.layer_metadata.layer_visible
	shared.get_parent().action_manager.commit_action(action)

	layer_data = shared.get_layer_at(layer_data.layer_metadata.order).layer_data
	show_hide.icon = eye_open if layer_data.layer_metadata.layer_visible else eye_closed


func panel_resized() -> void:
	if not is_instance_valid(collision_shape): return
	var rect_shape: RectangleShape2D = collision_shape.shape
	rect_shape.extents = panel_container.rect_size / 2
	collision_shape.position = panel_container.rect_size / 2


func dragger_down() -> void:
	is_dragging = true
	layer_dropdown.is_dragging = true
	modulate = Color(0.75, 1, 2)


func dragger_up() -> void:
	var drag_area: Area2D = layer_dropdown.drag_area
	
	is_dragging = false
	layer_dropdown.is_dragging = false
	drag_area.position = Vector2.ZERO
	modulate = Color.white
	
	if not drag_area.get_overlapping_areas().empty():
		var target_layer_info: LayerInfo = drag_area.get_overlapping_areas()[0].owner
		if target_layer_info != self:
			var action := ReorderLayerAction.new()
			action.shared = shared
			action.layer_index = layer_data.layer_metadata.order
			action.final_layer_index = target_layer_info.layer_data.layer_metadata.order
			layer_dropdown.editor.action_manager.commit_action(action)
			click_sound.play()


func area_entered(_area: Area2D):
	if is_dragging: return
	modulate.a = 0.75
	hover_sound.play()


func area_exited(_area: Area2D):
	modulate.a = 1.0
