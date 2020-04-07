extends EditorWindow

export var grid_container : NodePath
export var preview : NodePath
export var delete_button : NodePath
export var shared : NodePath

var object
var preview_object

onready var property_scene = load("res://scenes/editor/property.tscn")
onready var grid_container_node = get_node(grid_container)
onready var preview_node = get_node(preview)
onready var delete_button_node = get_node(delete_button)
onready var shared_node = get_node(shared)

func _ready():
	delete_button_node.connect("pressed", self, "delete_pressed")
	
func _process(delta):
	if object != null and object.get_ref() and preview_object:
		var obj_node = object.get_ref()
		preview_object.scale = Vector2(2.5, 2.5) * obj_node.scale
		preview_object.rotation_degrees = obj_node.rotation_degrees
		preview_object.visible = obj_node.visible
	
func delete_pressed():
	close()
	shared_node.destroy_object(object.get_ref(), true)
	object = null
	preview_object.queue_free()
	preview_object = null

func open_object(object: GameObject):
	for property in grid_container_node.get_children():
		property.queue_free()

	for child in preview_node.get_children():
		child.queue_free()
		
	preview_object = object.duplicate()
	preview_object.mode = 1
	for child in object.get_children():
		preview_object.z_index += 10
		preview_object.add_child(child)
	preview_object.set_property("enabled", false, false)
	preview_object.position = object.preview_position
	preview_object.z_index += 10
	preview_object.visible = true
	preview_object.modulate = Color(1, 1, 1)
	preview_object.scale = Vector2(2.5, 2.5) * object.scale
	preview_node.add_child(preview_object)

	self.object = weakref(object)
	for key in (object.editable_properties + object.base_editable_properties):
		var property = property_scene.instance()
		property.object = object
		property.key = key
		grid_container_node.add_child(property)
	for index in range(2): # this is so scrolling actually works properly
		var blank_property = property_scene.instance()
		blank_property.modulate.a = 0
		blank_property.set_process(false)
		blank_property.object = object
		blank_property.key = "position"
		grid_container_node.add_child(blank_property)
	open()
	
