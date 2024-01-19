extends NinePatchRect

export var close_button : NodePath
onready var object_property_button = $Control
onready var curve_points
onready var global_position
onready var path_node = load("res://scenes/editor/property_type_scenes/Path/PathNode.tscn")
onready var first_node : Node2D
onready var last_placed_node : Node2D
onready var editor = get_tree().get_current_scene()

func _ready():
	grab_focus()
	#draw the object's current curve2D
	
	print("loaded")


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
	object_property_button.get_parent().get_parent().get_parent().get_parent().get_parent().visible = true
	
func set_object_property_button(button: Control):
	object_property_button = button
	#object settings window lol
	object_property_button.get_parent().get_parent().get_parent().get_parent().get_parent().visible = false
	curve_points = button.get_value().get_baked_points()
	global_position = object_property_button.get_parent().get_parent().get_parent().get_parent().get_parent().object.get_ref().path.global_position
	for point in curve_points:
		add_node(point + global_position)
	var nextnode = first_node
	while(is_instance_valid(nextnode)):
		print(nextnode.position)
		print(nextnode.visible)
		nextnode = nextnode.nextnode

func close_pressed():
	close()
