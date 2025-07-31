extends PropertyTab


const TYPE_LOOKUP: Dictionary = {
	TYPE_BOOL: "bool",
	TYPE_INT: "int",
	TYPE_REAL: "fallback",
	TYPE_STRING: "fallback",
	TYPE_VECTOR2: "Vector2",
	TYPE_COLOR: "fallback"
}

const TAB_SCENE_PATH: String = "res://scenes/editor/windows/object_property_editor/misc_property_scenes/%s/base.tscn"
const FALLBACK_TYPE: String = "fallback"

var editor: Editor
var objects: Dictionary

func load_misc_properties(_editor: Editor, _objects: Dictionary, common_properties: Array):
	editor = _editor
	objects = _objects
	for property in common_properties:
		var property_type: String = TYPE_LOOKUP.get(property[1], FALLBACK_TYPE)
		var property_scene: PropertyEditor = load(TAB_SCENE_PATH % property_type).instance()
		property_scene.load_property(editor, objects, property)
		get_node("%Properties").add_child(property_scene)
