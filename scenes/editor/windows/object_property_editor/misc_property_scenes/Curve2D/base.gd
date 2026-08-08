extends PropertyEditor

onready var pathmaker_file = preload("res://scenes/editor/windows/object_property_editor/misc_property_scenes/Curve2D/pathmaker.tscn")
var curve_info: Array

func change_property(new_value):
	editor.get_node("%UI").visible = true
	var value = new_value.duplicate()
	.change_property(value)

func load_property(_editor: Editor, init_value, _property: Array, property_name = null):
	.load_property(_editor, init_value, _property, property_name)
	curve_info = init_value
	
func property_changed(key, value):
	.property_changed(key, value)
	if curve_info:
		curve_info[1] = LevelCodeSerializer.serialize_data(curve_info[0][property[0]])
	
func begin_curve():
	editor.get_node("%UI").visible = false
	var pathmaker = pathmaker_file.instance()
	pathmaker.name = "PathMaker"
	pathmaker.property_editor = self
	var init_curve: Curve2D = LevelCodeDeserializer.deserialize_data_code(curve_info[1])
	pathmaker.init_curve = init_curve if init_curve else Curve2D.new()
	pathmaker.object = curve_info[0]
	pathmaker.rect_position = curve_info[0].position
	editor.parallax_scroll.add_child(pathmaker)
