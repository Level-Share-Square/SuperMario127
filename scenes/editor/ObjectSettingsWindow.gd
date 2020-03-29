extends EditorWindow

export var contents : NodePath

var object

onready var property_scene = load("res://scenes/editor/property.tscn")
onready var contents_node = get_node(contents)

func open_object(object: GameObject):
	self.object = object
	for key in (object.editable_properties + object.base_editable_properties):
		var property = property_scene.instance()
		property.object = object
		property.key = key
		contents_node.add_child(property)
	open()
	
