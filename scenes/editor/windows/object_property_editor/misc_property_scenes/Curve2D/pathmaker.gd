extends Control

const VERTEX_PATH = preload("res://scenes/editor/tools/path_tool/path_node.tscn")
const DELETE_COLOR := Color("ff6060")

onready var line = $"%Line"
onready var path_node_container = $"%Icons"
onready var widget_container = $"%WidgetContainer"
onready var dist = $"%HSlider"
onready var handle = $"%Handle"
onready var handle_link = $"%HandleLink"
onready var previews = $"%Previews"
onready var delete_button = $"%Delete"
onready var confirm_button = $"%Confirm"
onready var property_editor

enum {MODE_PLACE, MODE_SELECT}

onready var object
var current_mode = MODE_PLACE

onready var selected_node : Node2D
onready var nodes = Array()
var init_curve
var delete: bool
onready var editor = get_parent()

var last_hovered_node
var amount: int = 3
var objects_array: Array
func _ready():
	line.get_node("path").curve = init_curve
	update_line()
	get_tree().current_scene.tool_manager.change_tool("%ObjectSelection")
	for point in line.get_node("path").curve.get_point_count():
		var texture_node = VERTEX_PATH.instance()
		nodes.append(texture_node)
		texture_node.ui = weakref(self)
		texture_node.position = line.get_node("path").curve.get_point_position(point)
		texture_node.is_object = true
		path_node_container.add_child(texture_node)
		if handle.pressed:
			texture_node.set_handles_active(true)
		if handle_link.pressed:
			texture_node._toggle_handle_link()
	if line.get_node("path").curve.get_point_count() < 1:
		widget_container.hide()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		get_tree().set_input_as_handled()
		widget_container.show()
		line.get_node("path").curve.add_point(get_mouse_pos() - object.position)
		update_line()
		var texture_node = VERTEX_PATH.instance()
		nodes.append(texture_node)
		texture_node.ui = weakref(self)
		texture_node.is_object = true
		texture_node.position = get_mouse_pos() - object.position
		path_node_container.add_child(texture_node)
		if handle.pressed:
			texture_node.set_handles_active(true)
		if handle_link.pressed:
			texture_node._toggle_handle_link()
	
func _on_Tools_tool_changed():
	objects_array.clear()
	line.clear_points()
	line.get_node("path").curve.clear_points()
	nodes.clear()
	for icon in path_node_container.get_children():
		icon.queue_free()
	for preview in previews.get_children():
		preview.queue_free()
	widget_container.hide()


func confirm():
	property_editor.change_property(line.get_node("path").curve)
	queue_free()

func update_node_position(node: Node2D):
	var index = nodes.find(node, 0)
	if index != -1:
		line.get_node("path").curve.set_point_position(index, node.position)
		update_line()
		
func update_node_handles(node: Node2D):
	var index = nodes.find(node, 0)
	if index != -1:
		line.get_node("path").curve.set_point_in(index, node.left_handle.position)
		line.get_node("path").curve.set_point_out(index, node.right_handle.position)
		update_line()

func delete_node(node : Node):
	if is_instance_valid(node) && nodes.has(node):
		var node_index : int = nodes.find(node)
		line.remove_point(node_index)
		line.get_node("path").curve.remove_point(node_index)
		nodes.remove(node_index)
		update_line()

func update_line():
	line.points = line.get_node("path").curve.get_baked_points()


func toggle_delete():
	delete = delete_button.pressed
	var tween: SceneTreeTween = create_tween()
	tween.tween_property(delete_button, "self_modulate", DELETE_COLOR if delete else Color.white, 0.2)

func toggle_handle_link():
	for node in nodes:
		node._toggle_handle_link()

func toggle_handles():
	for node in nodes:
		node.set_handles_active(handle.pressed)

func widget_move_to(node: Node):
	widget_container.rect_global_position = node.position + object.position + Vector2(-140, 16)
		
func get_mouse_pos() -> Vector2:
	return editor.corrected_mouse_position()


func copy():
	OS.set_clipboard("c" + LevelCodeSerializer.serialize_data(line.get_node("path").curve))
	
func paste():
	var clipboard: String = OS.get_clipboard()
	if not clipboard.begins_with("c"): return
	
	clipboard = clipboard.substr(1)
	init_curve = LevelCodeDeserializer.deserialize_data_code(clipboard)
	
	for node in path_node_container.get_children():
		node.queue_free()
		
	_ready()
