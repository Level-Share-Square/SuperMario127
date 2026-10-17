extends PropertyTab

const EVENT_PANEL = preload("res://scenes/editor/windows/object_property_editor/property_tabs/event/event_panel.tscn")
var event_prefab: Control

func _enter_tree():
	event_prefab = $"%EventPrefab"

func load_properties(_editor, _objects):
	editor = _editor
	objects = _objects
	
	var check_events: Array = []
	for object in objects.keys():
		if not object is EventTrigger:
			event_prefab.show_invalid_text()
			return
			
		if check_events.empty():
			check_events = object.events
			continue
		
		if check_events.size() != object.events.size():
			event_prefab.show_invalid_text()
			return
			
		for i in range(check_events.size()):
			if not check_events[i].check_equivalent(object.events[i]):
				event_prefab.show_invalid_text()
				return
				
	event_prefab.show_invalid_text(false)
	 
	var object: EventTrigger = objects.keys()[0]
	for event in object.events:
		var event_panel = EVENT_PANEL.instance()
		event_panel.held_event = event
		event_prefab.add_event(event_panel)
	
	event_prefab.load_info(object.event_start_text)

func on_properties_opened(event_panel: EventPanel):
	event_prefab.load_properties(self, event_panel)

