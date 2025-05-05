extends EditorWindow


var game_object: GameObject


func _ready():
	var data = ObjectData.new()
	data.properties = [Vector2(0, 0), Vector2(1, 1), 0.0, true, true, 3]
	
	load_object(data)


func load_object(object):
#	game_object = object
	var object_data: ObjectData = object
	
	for property in object_data.properties:
		create_property_editor(typeof(property))


func create_property_editor(type: int, tab: String = "Misc", editor_hints: Array = []):
	print("Creating property editor type %s at tab %s with editor hints %s." % [type, tab, editor_hints])
