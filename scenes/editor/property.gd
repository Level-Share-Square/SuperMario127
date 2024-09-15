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
		
	var all_property_value_menus = object.base_property_value_menus + object.property_value_menus
	
	var value = object[key] if key != "visible" else object.modulate.a == 1
	var menu
	if all_property_value_menus > object.base_property_value_menus:
		menu = all_property_value_menus[object.get_property_index(key)]
		print("Setting menu of " + key + " to " + menu[0] + " menu!")
	else:
		menu = ["base"]
		print("Setting menu of " + key + " to " + menu[0] + " menu!")
	var type = typeof(value)
	var type_scene_name := "None"
	#print(value)
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
	elif value is Curve2D:
		type_scene_name = "Path"
	elif type == TYPE_STRING_ARRAY:
		type_scene_name = "PoolStringArray"
	elif type == TYPE_VECTOR2_ARRAY:
		type_scene_name = "PoolVector2Array"
	
	
	if type_scene_name != "None":
		property_type = Singleton.MiscCache.get_property_scene(type_scene_name, menu[0]).instance()
		#print(property_type)
		add_child(property_type)
		
		if len(menu) > 1:
			for i in len(menu):
				if i != 0:
					property_type.parameters[i-1] = menu[i]
		
		property_type.set_value(value)
		

func get_value():
	return property_type.get_value()

func update_value(value):
	object.set_property(key, value, true)
