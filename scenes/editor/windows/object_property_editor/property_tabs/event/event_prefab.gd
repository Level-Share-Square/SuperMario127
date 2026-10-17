extends TabContainer

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

var start_info: Label
var event_container: Control
var event_list: EventList
var parent

func _enter_tree():
	event_container = $"%EventContainer"
	start_info = $"%StartInfo"
	event_list = $"%EventList"
	parent = get_parent()
	
func _ready() -> void:
	show_invalid_text(false)

func add_event(event_panel: EventPanel):
	event_container.add_child(event_panel)
	event_panel.populate_name()
	event_panel.connect("open_properties", parent, "on_properties_opened", [event_panel])
	current_tab = 0
	
func show_invalid_text(value: bool = true):
	current_tab = 3 if value else current_tab

func load_info(start_text: String):
	start_info.text = start_text
	event_list.populate_list()

func load_properties(connecting_scene: Node, event_panel: EventPanel):
	for child in get_node("%PropertiesContainer").get_children():
		child.queue_free()
	
	var event: Event = event_panel.held_event
	var editor = get_tree().current_scene
	for property in event.properties:
		if property in event.property_overrides:
			var override_data = event.property_overrides[property].duplicate(true)
			load_property_override(property, event, PropertyTab.OverrideTypes.keys()[override_data[0]], override_data, connecting_scene)
			continue
		var property_type: String = TYPE_LOOKUP.get(typeof(event.properties[property]), FALLBACK_TYPE)
		var property_scene: PropertyEditor = load(TAB_SCENE_PATH % property_type).instance()
		property_scene.window = editor.get_node("%ObjectSettingsWindow")

		property_scene.load_property(editor, event.properties[property], [property, typeof(event.properties[property]), event.properties[property]])
		connect_signals(property_scene, connecting_scene)
		get_node("%PropertiesContainer").add_child(property_scene)
		
	current_tab = 2

func load_property_override(override: String, event: Event, override_name: String, override_data, connecting_scene: Node):
	var property_scene: PropertyEditor = load("res://scenes/editor/windows/object_property_editor/misc_property_scenes/" + override_name.to_lower() + "/base.tscn").instance()
	var editor = get_tree().current_scene
	property_scene.load_property(editor, event.properties[override], override_data[1])
	connect_signals(property_scene, connecting_scene)
	get_node("%Properties").add_child(property_scene)

func connect_signals(property_editor: PropertyEditor, connecting_scene: Node):
	property_editor.connect("property_edited", connecting_scene, "change_property")
