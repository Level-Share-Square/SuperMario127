extends PropertyTab

const EVENT_PANEL = preload("res://scenes/editor/windows/object_property_editor/property_tabs/event/event_panel.tscn")
var event_prefab: Control

func _enter_tree():
	event_prefab = $"%EventPrefab"

func load_properties(_editor, _objects):
	editor = _editor
	objects = _objects
	
	# will this still work with editing events on multiple objects at once?
	# make sure to account for that in some way  
	var object: EventTrigger = objects.keys()[0]
	for event in object.events:
		var event_panel = EVENT_PANEL.instance()
		event_panel.held_event = event
		event_prefab.add_event(event_panel)
	
	event_prefab.load_info(object.event_start_text)
