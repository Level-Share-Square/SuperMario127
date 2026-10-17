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

const EVENT_PANEL = preload("res://scenes/editor/windows/object_property_editor/property_tabs/event/event_panel.tscn")
const TAB_SCENE_PATH: String = "res://scenes/editor/windows/object_property_editor/misc_property_scenes/%s/base.tscn"
const FALLBACK_TYPE: String = "fallback"

var start_info: Label
var event_container: Control
var event_list: EventList
var parent

var event_selected: Event
var new_properties: Dictionary = {}

signal finished_editing(event, new_properties)
signal added_new_event(event)
signal delete_event(event)

func _enter_tree():
	event_container = $"%EventContainer"
	start_info = $"%StartInfo"
	event_list = $"%EventList"
	parent = get_parent()
	
func _ready() -> void:
	show_invalid_text(false)
	
	var action_manager: ActionManager = get_tree().current_scene.action_manager
	action_manager.connect("action", self, "handle_action", [action_manager])
	action_manager.connect("redo", self, "handle_action", [action_manager])
	action_manager.connect("undo", self, "handle_action", [action_manager])

func add_event(event_panel: EventPanel):
	event_container.add_child(event_panel)
	event_panel.populate_name()
	event_panel.connect("open_properties", parent, "on_properties_opened", [event_panel])
	current_tab = 0
	
func populate_events(events: Array):
	clear_events()
	for event in events:
		var event_panel = EVENT_PANEL.instance()
		event_panel.held_event = event
		add_event(event_panel)
	
func handle_action(action_manager):
	var actions: Array = [action_manager.undo_stack.back(), action_manager.redo_stack.back()]
	var found_action: bool = false
	for stack in actions:
		if stack == null: continue
		for action in stack:
			if (action is ChangeEventAction):
				found_action = true
				break
	if !found_action: return
	
	var events: Array = []
	for event_panel in event_container.get_children():
		events.append(event_panel.held_event)
	
	populate_events(events)
	current_tab = 0
	
	
func clear_events():
	for child in event_container.get_children():
		child.queue_free()
	
func show_invalid_text(value: bool = true):
	current_tab = 3 if value else current_tab

func load_info(start_text: String):
	start_info.text = start_text
	event_list.populate_list()

func load_properties(event_panel: EventPanel):
	for child in get_node("%PropertiesContainer").get_children():
		child.queue_free()
	
	event_selected = event_panel.held_event
	new_properties = event_selected.properties.duplicate(true)
	var editor = get_tree().current_scene
	for property in event_selected.properties:
		if property == "event": continue # hacky
		if property in event_selected.property_overrides:
			var override_data = event_selected.property_overrides[property].duplicate(true)
			load_property_override(property, event_selected, PropertyTab.OverrideTypes.keys()[override_data[0]], override_data)
			continue
		var property_type: String = TYPE_LOOKUP.get(typeof(event_selected.properties[property]), FALLBACK_TYPE)
		var property_scene: PropertyEditor = load(TAB_SCENE_PATH % property_type).instance()
		property_scene.window = editor.get_node("%ObjectSettingsWindow")

		property_scene.load_property(editor, event_selected.properties[property], [property, typeof(event_selected.properties[property]), event_selected.properties[property]])
		connect_signals(property_scene)
		get_node("%PropertiesContainer").add_child(property_scene)
		
	current_tab = 2

func load_property_override(override: String, event: Event, override_name: String, override_data):
	var property_scene: PropertyEditor = load("res://scenes/editor/windows/object_property_editor/misc_property_scenes/" + override_name.to_lower() + "/base.tscn").instance()
	var editor = get_tree().current_scene
	property_scene.load_property(editor, event.properties[override], override_data[1])
	connect_signals(property_scene)
	get_node("%Properties").add_child(property_scene)

func connect_signals(property_editor: PropertyEditor):
	property_editor.connect("property_edited", self, "change_property")

func change_property(property: String, new_value, check_matches, save_to_data):
	new_properties[property] = new_value

func on_finished_editing_properties():
	emit_signal("finished_editing", event_selected, new_properties)

func add_new_event(event_panel):
	emit_signal("added_new_event", event_panel.held_event)

func on_delete_event():
	emit_signal("delete_event", event_selected)
