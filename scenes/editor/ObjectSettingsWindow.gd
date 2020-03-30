extends EditorWindow

export var grid_container : NodePath
export var preview_sprite : NodePath

var object

onready var property_scene = load("res://scenes/editor/property.tscn")
onready var grid_container_node = get_node(grid_container)
onready var preview_sprite_node = get_node(preview_sprite)

func open_object(object: GameObject):
	for property in grid_container_node.get_children():
		property.queue_free()
		
	self.object = object
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
	
