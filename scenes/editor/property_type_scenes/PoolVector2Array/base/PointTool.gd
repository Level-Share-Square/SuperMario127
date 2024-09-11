extends Control

var point_node = preload("res://scenes/editor/property_type_scenes/PoolVector2Array/base/PointNode.tscn")

export var close_button : NodePath
onready var object_property_button = get_parent()
onready var cursor = $Sprite

onready var selected_node : Node2D

onready var point_node_container = Node2D.new()
onready var nodes = Array()

var point_list : PoolVector2Array

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
	editor.add_child(point_node_container)
	
	set_object_property_button(object_ref)
	point_node_container.transform = editing_object.transform
	inverse_transform = point_node_container.transform.affine_inverse()
	

func _process(delta):
	mouse_position = Vector2(stepify(point_node_container.get_local_mouse_position().x, 16), stepify(point_node_container.get_local_mouse_position().y, 16))
	
	cursor.position = cursor.to_local(mouse_position)
		# this makes the editor unable to do anything
	editor.selected_tool = 3
	if Input.is_action_just_pressed("place") and get_viewport().get_mouse_position().y > 70:

		if is_instance_valid(last_hovered_node) && last_hovered_node.check_if_hovered() == false && current_mode == MODE_SELECT:
			selected_node.deselect()
		if current_mode == MODE_PLACE && !($CloseButton.is_hovered() || $ConfirmButton.is_hovered()):
			add_node(inverse_transform.xform(editor.get_global_mouse_position()))


func add_node(point : Vector2, point_in: Vector2 = Vector2.ZERO, point_out: Vector2 = Vector2.ZERO):
	var new_node = point_node.instance()
	new_node.ui = weakref(self)
	point_node_container.add_child(new_node)
	nodes.push_back(new_node)
	new_node.position = point
	point_list.push_back(point)
	if(new_node.position == Vector2(0,0)):
		new_node.first = true

func delete_node(node : Node):
	if is_instance_valid(node) && nodes.has(node):
		var node_index : int = nodes.find(node)
		nodes.remove(node_index)

func close():
	point_node_container.queue_free()
	#TODO: Make a hide function for the editor window.
	editor.object_settings.visible = true
	editor.selected_tool = 0
	
	queue_free()
	
func set_object_property_button(button: Control):
	object_property_button = button
	point_node_container.position = editing_object.position
	#object settings window lol
	#TODO: Make this use a reference to the object rather than a reference to the property button.
	#TODO: Add an object reference to the property button.
	#TODO: Make a hide function for the editor window.
	var current_points = button.get_value()
	editor.object_settings.visible = false
	for i in range(0, len(current_points)):
		add_node(current_points[i])
	#var nextnode = first_node
	#while(is_instance_valid(nextnode)):
	#    print(nextnode.position)
	#    print(nextnode.visible)
	#    nextnode = nextnode.nextnode

func close_pressed():
	close()

func _confirm_pressed():
	var return_points = object_property_button.get_value()
	return_points.clear()
	var index = 0
	for node in nodes:
		return_points.push_back(node.position)
		index += 1
	object_property_button.set_value(return_points)
	print(return_points)
	close()
