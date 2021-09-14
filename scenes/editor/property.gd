extends Control

var object : GameObject
var key : String
var alias : String

onready var label = $Label

var property_type

func _ready():
	if object.has_editor_alias(key):
		label.text = object.get_editor_alias(key)
	else:
		label.text = key.capitalize()
	
	var value = object[key] if key != "visible" else object.modulate.a == 1
	var type = typeof(value)
	var type_scene_name := "None"
	if type == TYPE_VECTOR2:
		type_scene_name = "Vector2"
	elif type == TYPE_INT:
		type_scene_name = "int"
	elif type == TYPE_REAL:
		type_scene_name = "float"
	elif type == TYPE_STRING:
		type_scene_name = "string"
	elif type == TYPE_BOOL:
		type_scene_name = "bool"
	elif type == TYPE_COLOR:
		type_scene_name = "Color"
	
	if type_scene_name != "None":
		property_type = Singleton.MiscCache.property_scenes[type_scene_name].instance()
		add_child(property_type)
		property_type.set_value(value)

func get_value():
	return property_type.get_value()

func update_value(value):
	object.set_property(key, value, true)
