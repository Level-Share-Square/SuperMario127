class_name EventList
extends VBoxContainer

const EVENT_IDS: PoolStringArray = preload("res://scenes/actors/events/ids.tres").ids
const EVENT_PATH: String = "res://scenes/actors/events/%s.gd"
const EVENT_PANEL: PackedScene = preload("res://scenes/editor/windows/object_property_editor/property_tabs/event/event_panel.tscn")

signal add_event(event_panel)

func populate_list() -> void:
	for child in get_children():
		child.queue_free()
	
	for id in EVENT_IDS:
		var event: Event = load(EVENT_PATH % id).new()
		var event_panel: EventPanel = EVENT_PANEL.instance()
		event_panel.held_event = event
		event_panel.is_list_event = true
		add_child(event_panel)
		event_panel.populate_name()
		event_panel.connect("event_picked", self, "event_picked", [event_panel])

func event_picked(picked_panel: EventPanel) -> void:
	var event_panel: EventPanel = EVENT_PANEL.instance()
	event_panel.held_event = picked_panel.held_event
	emit_signal("add_event", event_panel)
