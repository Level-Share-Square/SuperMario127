extends Control

var path_node = preload("res://scenes/editor/property_type_scenes/Path/PathNode.tscn")
var line_node = preload("res://scenes/editor/property_type_scenes/Path/Line.tscn")

export var close_button : NodePath
onready var object_property_button = $Control
onready var line
onready var path_node_container = Node2D.new()
onready var nodes = Array()

var editor
# the object which has the path
var editing_object: GameObject


func _ready():
	pass

func initialize(object_ref):
	editor = get_tree().get_current_scene()
	editor.add_child(path_node_container)
	
	set_object_property_button(object_ref)
	
	

func _process(delta):
	# this makes the editor unable to do anything
	editor.selected_tool = 3
	if Input.is_action_just_pressed("place") and get_viewport().get_mouse_position().y > 70:
		add_node(path_node_container.get_global_transform().xform_inv(editor.get_global_mouse_position()))
		
		
func _gui_input(event) -> void:
	if event.is_action_released("place"):
		add_node(path_node_container.get_global_transform().xform_inv(editor.get_global_mouse_position()))
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
	for point in range(0, button.get_value().get_point_count()):
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
