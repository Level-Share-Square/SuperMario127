extends TextureButton

onready var icon = get_node("Icon")
export var object : NodePath = ""

func change_object(new_object):
	object = new_object
	var object_node = get_node(object)
	
	if object != null and object != "":
		icon.texture = object_node.icon
	else:
		icon.texture = null

func _ready():
	change_object(object)
	pass
