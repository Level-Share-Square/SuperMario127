extends Node

var path_node = preload("res://scenes/editor/property_type_scenes/Path/PathNode.tscn")

export var close_button : NodePath
onready var object_property_button = $Control
onready var curve_points
onready var global_position
onready var first_node : Node2D
onready var last_placed_node : Node2D
var editor

var editing_object: GameObject


func _ready():
	pass

func initialize(object_ref):
	set_object_property_button(object_ref)
	editor.selected_tool = 3

func _process(delta):
	pass
		
		
func _unhandled_input(event) -> void:
	if event.is_action_released("ui_accept"):
		print("true")
		add_node(editor.last_mouse_pos)
	
func add_node(point : Vector2):
	var new_node = path_node.instance()
	new_node.position = point
	print("position")
	print(new_node.position)
	if !is_instance_valid(first_node):
		first_node = new_node
		editor.add_child(new_node)
	else:
		first_node.add_child(new_node)
		new_node.prevnode = last_placed_node
		last_placed_node.nextnode = new_node
	print(new_node.get_parent())
	last_placed_node = new_node
	
func close():
	first_node.queue_free()
	queue_free()
	#TODO: Make a hide function for the editor window.
	editor.object_settings.visible = true
	
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
