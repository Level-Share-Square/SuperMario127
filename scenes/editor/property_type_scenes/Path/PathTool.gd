extends Control

var path_node = preload("res://scenes/editor/property_type_scenes/Path/PathNode.tscn")
var line_node = preload("res://scenes/editor/property_type_scenes/Path/Line.tscn")

export var close_button : NodePath
onready var object_property_button = $Control
onready var line
onready var curve_points
onready var global_position
onready var first_node : Node2D
onready var selected_node : Control
onready var last_placed_node : Node2D
onready var path_node_container = Node2D.new()
onready var nodes = Array()

var editor

var editing_object: GameObject
var editing_object_transform: Transform2D

enum {MODE_PLACE, MODE_SELECT}

var current_mode = MODE_PLACE

#TODO: Make node deselection work without this.
var _click_buffer: int = 0

func _ready():
	pass

func initialize(object_ref):
	editor = get_tree().get_current_scene()
	editor.add_child(path_node_container)
	
	set_object_property_button(object_ref)
	
	

func _process(delta):
	editor.selected_tool = 3
	if Input.is_action_just_pressed("place") and get_viewport().get_mouse_position().y > 70:
		
		if _click_buffer == 1 && current_mode == MODE_SELECT:
			_click_buffer = 0
			selected_node.release_focus()
		
		if current_mode == MODE_PLACE:
			add_node(path_node_container.get_global_transform().xform_inv(editor.get_global_mouse_position()))
		else:
			_click_buffer += 1

			
			

		

		
		
func _gui_input(event) -> void:
	if event.is_action_released("place"):
		if current_mode == MODE_PLACE:
			add_node(path_node_container.get_global_transform().xform_inv(editor.get_global_mouse_position()))
		elif _click_buffer != 0:
			_click_buffer = 0
			selected_node.release_focus()
		accept_event()


	
func add_node(point : Vector2):
	var new_node = path_node.instance()
	new_node.ui = weakref(self)
	path_node_container.add_child(new_node)
	nodes.push_back(new_node)
	new_node.rect_position = point
	line.add_point(point)
	if(new_node.rect_position == Vector2(0,0)):
		new_node.first = true
		
func node_deleted():
	for i in range(nodes.size()):
		if(nodes[i].is_queued_for_deletion()):
			nodes.remove(i)
			line.remove_point(i)
			break
			
	
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
	editor.object_settings.visible = false
	curve_points = button.get_value().get_point_count()
	global_position = editing_object.global_position
	editing_object_transform = editing_object.get_global_transform()
	print(button.get_value().get_point_count())
	for point in range(0, curve_points):
		add_node(button.get_value().get_point_position(point))
	#var nextnode = first_node
	#while(is_instance_valid(nextnode)):
	#    print(nextnode.position)
	#    print(nextnode.visible)
	#    nextnode = nextnode.nextnode

func close_pressed():
	close()


func _confirm_pressed():
	var return_curve = object_property_button.get_value()
	return_curve.clear_points()
	for node in nodes:
		return_curve.add_point(node.rect_position)
	object_property_button.set_value(return_curve)
	close()
