extends Node

var path_node = preload("res://scenes/editor/property_type_scenes/Path/PathNode.tscn")
var line_node = preload("res://scenes/editor/property_type_scenes/Path/Line.tscn")

export var close_button : NodePath
onready var object_property_button = $Control
onready var line
onready var curve_points
onready var global_position
onready var first_node : Node2D
onready var last_placed_node : Node2D
onready var path_node_container = Node2D.new()
onready var nodes = Array()

var editor

var editing_object: GameObject
var editing_object_transform: Transform2D


func _ready():
	pass

func initialize(object_ref):
	editor = get_tree().get_current_scene()
	editor.add_child(path_node_container)
	set_object_property_button(object_ref)
	
	

func _process(delta):
	pass
		
		
func _unhandled_input(event) -> void:
	if event.is_action_released("ui_accept"):
		print("true")
		add_node(path_node_container.get_global_transform().xform_inv(editor.get_global_mouse_position()))
	
func add_node(point : Vector2):
	var new_node = path_node.instance()
	path_node_container.add_child(new_node)
	nodes.push_back(new_node)
	new_node.position = point
	line.add_point(point)
	print("position")
	print(new_node.position)
	
func close():
	path_node_container.queue_free()
	#TODO: Make a hide function for the editor window.
	editor.object_settings.visible = true
	
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
	editor.object_settings.visible = false
	curve_points = button.get_value().get_baked_points()
	global_position = editing_object.global_position
	editing_object_transform = editing_object.get_global_transform()
	for point in curve_points:
		add_node(point)
	#var nextnode = first_node
	#while(is_instance_valid(nextnode)):
	#	print(nextnode.position)
	#	print(nextnode.visible)
	#	nextnode = nextnode.nextnode

func close_pressed():
	close()


func _confirm_pressed():
	var return_curve = object_property_button.get_value()
	return_curve.clear_points()
	for node in nodes:
		return_curve.add_point(node.position)
	object_property_button.set_value(return_curve)
	close()
