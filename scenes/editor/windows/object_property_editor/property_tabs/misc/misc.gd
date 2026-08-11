extends PropertyTab


const TYPE_LOOKUP: Dictionary = {
	TYPE_BOOL: "bool",
	TYPE_INT: "int",
	TYPE_REAL: "float",
	TYPE_STRING: "String",
	TYPE_VECTOR2: "Vector2",
	TYPE_COLOR: "Color",
	TYPE_OBJECT: "Curve2D"
}

const TAB_SCENE_PATH: String = "res://scenes/editor/windows/object_property_editor/misc_property_scenes/%s/base.tscn"
const FALLBACK_TYPE: String = "fallback"

func load_misc_properties(_editor: Editor, _objects: Dictionary, common_properties: Array, common_property_overrides: Array):
	editor = _editor
	objects = _objects

	for property in common_properties:
		if property[0] in common_property_overrides:
			var override_data = objects.keys()[0].property_overrides[property[0]]
			load_property_override(property[0], OverrideTypes.keys()[override_data[0]], override_data)
			continue
		var property_type: String = TYPE_LOOKUP.get(property[1], FALLBACK_TYPE)
		var property_scene: PropertyEditor = load(TAB_SCENE_PATH % property_type).instance()
		property_scene.load_property(editor, get_property_value(objects.keys()[0], property[0]), property)
		connect_signals(property_scene)
		get_node("%Properties").add_child(property_scene)

func load_property_override(override: String, override_name: String, override_data):
	var property_scene: PropertyEditor = load("res://scenes/editor/windows/object_property_editor/misc_property_scenes/" + override_name.to_lower() + "/base.tscn").instance()
	property_scene.load_property(editor, get_property_value(objects.keys()[0], override), override_data[1])
	connect_signals(property_scene)
	get_node("%Properties").add_child(property_scene)
