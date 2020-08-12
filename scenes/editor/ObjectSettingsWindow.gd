extends EditorWindow

export var grid_container : NodePath
export var preview : NodePath
export var delete_button : NodePath
export var shared : NodePath

var object
var preview_object

onready var property_scene = preload("res://scenes/editor/property.tscn")
onready var grid_container_node = get_node(grid_container)
onready var preview_node = get_node(preview)
onready var delete_button_node = get_node(delete_button)
onready var shared_node = get_node(shared)

func _ready():
	var _connect = delete_button_node.connect("pressed", self, "delete_pressed")
	
func delete_pressed():
	close()
	shared_node.destroy_object(object.get_ref(), true)
	object = null
	preview_object.queue_free()
	preview_object = null
	
func edit_preview_object(key, value):
	if object != null and object.get_ref() and is_instance_valid(preview_object):
		if key != "position" and key != "enabled":
			if key != "scale":
				preview_object[key] = value
			else:
				preview_object[key] = Vector2(2.5, 2.5) * value

func open_object(object_to_open: GameObject):
	for property in grid_container_node.get_children():
		property.queue_free()

	for child in preview_node.get_children():
		child.queue_free()
		
	# warning-ignore:return_value_discarded
	object_to_open.connect("property_changed", self, "edit_preview_object")

	preview_object = object_to_open.duplicate()
	preview_object.mode = 1
	preview_object.set_property("enabled", false, false)
	preview_object.position = object_to_open.preview_position
	preview_object.z_index += 10
	preview_object.visible = true
	preview_object.modulate = Color(1, 1, 1)
	preview_object.scale = Vector2(2.5, 2.5) * object_to_open.scale
	preview_node.add_child(preview_object)

	object = weakref(object_to_open)
	for key in (object_to_open.editable_properties + object_to_open.base_editable_properties):
		var property = property_scene.instance()
		property.object = object_to_open
		property.key = key
		edit_preview_object(key, object_to_open[key])
		grid_container_node.add_child(property)
		
	for _index in range(2): # this is so scrolling actually works properly
		var blank_property = property_scene.instance()
		blank_property.modulate.a = 0
		blank_property.set_process(false)
		blank_property.object = object_to_open
		blank_property.key = "position"
		grid_container_node.add_child(blank_property)
	open()
	
