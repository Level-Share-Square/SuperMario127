extends EditorWindow

export var grid_container : NodePath

var object

onready var property_scene = load("res://scenes/editor/property.tscn")
onready var grid_container_node = get_node(grid_container)

func open_object(object: GameObject):
	self.object = object
	for key in (object.editable_properties + object.base_editable_properties):
		var property = property_scene.instance()
		property.object = object
		property.key = key
		grid_container_node.add_child(property)
	open()
	
