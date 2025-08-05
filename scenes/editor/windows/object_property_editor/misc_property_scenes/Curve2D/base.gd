extends PropertyEditor

onready var pathmaker_file = preload("res://scenes/editor/windows/object_property_editor/misc_property_scenes/Curve2D/pathmaker.tscn")

var text_begin: String

func change_property(new_value):
	editor.get_node("%UI").visible = true
	.change_property(new_value)


func begin_curve():
	editor.get_node("%UI").visible = false
	var pathmaker = pathmaker_file.instance()
	pathmaker.name = "PathMaker"
	pathmaker.property_editor = self
	editor.add_child(pathmaker)
