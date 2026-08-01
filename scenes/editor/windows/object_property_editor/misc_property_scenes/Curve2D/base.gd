extends PropertyEditor

onready var pathmaker_file = preload("res://scenes/editor/windows/object_property_editor/misc_property_scenes/Curve2D/pathmaker.tscn")
var init_curve: Curve2D

func change_property(new_value):
	editor.get_node("%UI").visible = true
	var value = new_value.duplicate()
	.change_property(value)

func load_property(_editor: Editor, _objects: Dictionary, _property: Array, property_name = null):
	.load_property(_editor, _objects, _property, property_name)
	init_curve = old_value_util.decode_value(_property[2])
	
func begin_curve():
	editor.get_node("%UI").visible = false
	var pathmaker = pathmaker_file.instance()
	pathmaker.name = "PathMaker"
	pathmaker.property_editor = self
	pathmaker.init_curve = init_curve
	pathmaker.object = objects.keys()[0]
	pathmaker.rect_position = objects.keys()[0].position
	editor.add_child(pathmaker)
