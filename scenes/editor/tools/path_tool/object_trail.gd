extends EditorTool

const VERTEX_PATH = preload("res://scenes/editor/tools/path_tool/path_node.tscn")

onready var line = $"%Line"
onready var path_node_container = $"%Icons"
onready var widget_container = $"%WidgetContainer"
onready var dist = $"%HSlider"
onready var handle = $"%Handle"
onready var handle_link = $"%HandleLink"
onready var previews = $"%Previews"

enum {MODE_PLACE, MODE_SELECT}

var current_mode = MODE_PLACE

onready var selected_node : Node2D
onready var nodes = Array()

var delete: bool

var last_hovered_node
var amount: int = 3
var objects_array: Array

func _ready():
	widget_container.hide()

func _click_left(_event: InputEvent, _world_pos: Vector2):
	widget_container.show()
	line.get_node("path").curve.add_point(_world_pos)
	update_line()
	var texture_node = VERTEX_PATH.instance()
	nodes.append(texture_node)
	texture_node.ui = weakref(self)
	texture_node.position = get_global_mouse_position()
	path_node_container.add_child(texture_node)
	widget_move_to(texture_node)
	if handle.pressed:
		texture_node.set_handles_active(true)
	if handle_link.pressed:
		texture_node._toggle_handle_link()
	update_objects_array()


func create_object_data(position: Vector2, object_id: int, palette: int) -> ObjectData:
	var metadata := ObjectMetadata.new(position, object_id, palette)
	var data := ObjectData.new(metadata)
	
	return data
	
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


func _on_Check_button_down():
	update_objects_array()
	var action := PlaceObjectBulkAction.new()
	action.shared = shared
	action.objects = objects_array
	action.layer = editor.layer
	editor.action_manager.commit_action(action)
	_on_Tools_tool_changed()

func update_node_position(node: Node2D):
	var index = nodes.find(node, 0)
	if index != -1:
		line.get_node("path").curve.set_point_position(index, node.position)
		update_line()
		if index == line.get_node("path").curve.get_point_count() - 1:
			widget_container.rect_global_position = Array(line.points).back() + Vector2(-140, 16)
		update_objects_array()
		
func update_node_handles(node: Node2D):
	var index = nodes.find(node, 0)
	if index != -1:
		line.get_node("path").curve.set_point_in(index, node.left_handle.position)
		line.get_node("path").curve.set_point_out(index, node.right_handle.position)
		update_line()
		update_objects_array()

func delete_node(node : Node):
	if is_instance_valid(node) && nodes.has(node):
		var node_index : int = nodes.find(node)
		line.remove_point(node_index)
		line.get_node("path").curve.remove_point(node_index)
		nodes.remove(node_index)
		update_line()

func update_line():
	line.points = line.get_node("path").curve.get_baked_points()


func _on_Delete_button_down():
	delete = !$WidgetContainer/VBoxContainer/HBoxContainer/Delete.pressed


func _on_HandleLink_button_down():
	for node in nodes:
		node._toggle_handle_link()


func _on_Handle_button_down():
	for node in nodes:
		node.set_handles_active(!$WidgetContainer/VBoxContainer/HBoxContainer/Handle.pressed)

func widget_move_to(node: Node):
	widget_container.rect_global_position = node.position + Vector2(-140, 16)

func update_objects_array() -> void:
	objects_array = []
	for preview in previews.get_children():
		preview.queue_free()
	var counter: int
	for point in line.points:
		if line.points.size() - 1 != line.points.find(point):
			counter += 1
			if counter == dist.value:
				var data = create_object_data(point, editor.selected_item.object_id, editor.selected_item.palette)
				objects_array.append(data)
				counter = 0
	for object in objects_array:
		var preview = TextureRect.new()
		preview.texture = editor.selected_item.previews[editor.selected_item.palette]
		preview.rect_position = object.metadata.position - preview.texture.get_size()/2
		preview.modulate.a = 0.5
		preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
		previews.add_child(preview)
		


func _on_HSlider_value_changed(value):
	update_objects_array()
