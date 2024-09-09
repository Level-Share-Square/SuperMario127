extends Control

var path_node = preload("res://scenes/editor/property_type_scenes/Path/base/PathNode.tscn")
var line_node = preload("res://scenes/editor/property_type_scenes/Path/base/Line.tscn")

export var close_button : NodePath
onready var object_property_button = $Control
onready var cursor = $Sprite
onready var line

onready var selected_node : Node2D

onready var path_node_container = Node2D.new()
onready var nodes = Array()

var node_positions : Dictionary

var inverse_transform : Transform2D
var editor
# the object which has the path
var editing_object: GameObject

enum {MODE_PLACE, MODE_SELECT}

var current_mode = MODE_PLACE


var last_hovered_node
var mouse_position

func _ready():
	pass

func initialize(object_ref):
	editor = get_tree().get_current_scene()
	editor.add_child(path_node_container)
	
	set_object_property_button(object_ref)
	path_node_container.transform = editing_object.transform
	inverse_transform = path_node_container.transform.affine_inverse()
	

func _process(delta):
	mouse_position = Vector2(stepify(path_node_container.get_local_mouse_position().x, 16), stepify(path_node_container.get_local_mouse_position().y, 16))
	
	cursor.position = cursor.to_local(mouse_position)
		# this makes the editor unable to do anything
	editor.selected_tool = 3
	if Input.is_action_just_pressed("place") and get_viewport().get_mouse_position().y > 70:

		if is_instance_valid(last_hovered_node) && last_hovered_node.check_if_hovered() == false && current_mode == MODE_SELECT:
			selected_node.deselect()
		if current_mode == MODE_PLACE && !($CloseButton.is_hovered() || $ConfirmButton.is_hovered()):
			add_node(inverse_transform.xform(editor.get_global_mouse_position()))


func add_node(point : Vector2, point_in: Vector2 = Vector2.ZERO, point_out: Vector2 = Vector2.ZERO):
	var new_node = path_node.instance()
	var curve_ref = line.get_node("path").curve
	new_node.ui = weakref(self)
	path_node_container.add_child(new_node)
	nodes.push_back(new_node)
	new_node.position = point
	curve_ref.add_point(point)
	if point_in != Vector2.ZERO || point_out != Vector2.ZERO:
		new_node.set_handles_active(true)
		curve_ref.set_point_in(curve_ref.get_point_count() - 1, point_in)
		new_node.move_handle(new_node.HANDLE_LEFT, point_in)
		curve_ref.set_point_out(curve_ref.get_point_count() - 1, point_out)
		new_node.move_handle(new_node.HANDLE_RIGHT, point_out)
		if point_in == -point_out && (point_in.x != -24 || point_out.x != 24):
			new_node.handles_linked = true
	update_line()
	if(new_node.position == Vector2(0,0)):
		new_node.first = true

func delete_node(node : Node):
	if is_instance_valid(node) && nodes.has(node):
		var node_index : int = nodes.find(node)
		line.remove_point(node_index)
		line.get_node("path").curve.remove_point(node_index)
		nodes.remove(node_index)
		update_line()


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


func close():
	path_node_container.queue_free()
	#TODO: Make a hide function for the editor window.
	editor.object_settings.visible = true
	editor.selected_tool = 0
	
	queue_free()
	
	
func set_object_property_button(button: Control):
	object_property_button = button
	path_node_container.position = editing_object.position
	line = line_node.instance()
	path_node_container.add_child(line)
	#object settings window lol
	#TODO: Make this use a reference to the object rather than a reference to the property button.
	#TODO: Add an object reference to the property button.
	#TODO: Make a hide function for the editor window.
	var current_curve = button.get_value()
	editor.object_settings.visible = false
	for point in range(0, current_curve.get_point_count()):
		add_node(current_curve.get_point_position(point), current_curve.get_point_in(point), current_curve.get_point_out(point))
	#var nextnode = first_node
	#while(is_instance_valid(nextnode)):
	#    print(nextnode.position)
	#    print(nextnode.visible)
	#    nextnode = nextnode.nextnode

func close_pressed():
	close()

func update_line():
	line.points = line.get_node("path").curve.get_baked_points()

func _confirm_pressed():
	var return_curve = object_property_button.get_value()
	return_curve.clear_points()
	var index = 0
	for node in nodes:
		return_curve.add_point(node.position)
		return_curve.set_point_in(index, node.left_handle.position * int(node.left_handle_enabled))
		return_curve.set_point_out(index, node.right_handle.position * int(node.right_handle_enabled))
		index += 1
	object_property_button.set_value(return_curve)
	close()
