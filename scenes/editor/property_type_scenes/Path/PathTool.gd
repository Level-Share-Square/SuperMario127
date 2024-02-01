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

var editor

var editing_object: GameObject


func _ready():
	pass

func initialize(object_ref):
	editor = get_tree().get_current_scene()
	set_object_property_button(object_ref)
	
	

func _process(delta):
	pass
		
		
func _unhandled_input(event) -> void:
	if event.is_action_released("ui_accept"):
		print("true")
		add_node(editor.get_global_mouse_position() - first_node.position)
	
func add_node(point : Vector2):
	var new_node = path_node.instance()
	new_node.position = point
	print("position")
	print(new_node.position)
	
	
	if !is_instance_valid(first_node):
		first_node = new_node
		editor.add_child(new_node)
		line = line_node.instance()
		new_node.add_child(line)
		line.add_point(Vector2(0,0))
	else:
		first_node.add_child(new_node)
		new_node.prevnode = last_placed_node
		last_placed_node.nextnode = new_node
		line.add_point(point)
	last_placed_node = new_node
	
func close():
	first_node.queue_free()
	#TODO: Make a hide function for the editor window.
	editor.object_settings.visible = true
	
	queue_free()
	
	
func set_object_property_button(button: Control):
	object_property_button = button
	#object settings window lol
	#TODO: Make this use a reference to the object rather than a reference to the property button.
	#TODO: Add an object reference to the property button.
	#TODO: Make a hide function for the editor window.
	editor.object_settings.visible = false
	curve_points = button.get_value().get_baked_points()
	global_position = editing_object.global_position
	for point in curve_points:
		add_node(point + global_position)
	var nextnode = first_node
	while(is_instance_valid(nextnode)):
		print(nextnode.position)
		print(nextnode.visible)
		nextnode = nextnode.nextnode

func close_pressed():
	close()


func _confirm_pressed():
	var return_curve = object_property_button.get_value()
	return_curve.clear_points()
	var node = first_node
	while(is_instance_valid(node.nextnode)):
		return_curve.add_point(node.to_global(node.position))
		node = node.nextnode
	object_property_button.set_value(return_curve)
	close()
