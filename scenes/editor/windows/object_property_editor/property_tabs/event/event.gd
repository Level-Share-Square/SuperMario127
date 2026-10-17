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
	event_prefab.clear_events()
	
	var object: EventTrigger = objects.keys()[0]
	event_prefab.populate_events(object.events)
	event_prefab.load_info(object.event_start_text)
	event_prefab.current_tab = 0

func on_properties_opened(event_panel: EventPanel):
	event_prefab.load_properties(event_panel)

func on_finished_editing(event, new_properties):
	var event_trigger: EventTrigger = objects.keys()[0]
	
	var event_index = event_trigger.events.find(event)
	var actions: Array = []
	for object in objects.keys():
		var action := ChangeEventAction.new()
		action.event = object.events[event_index]
		action.new_properties = new_properties
		actions.append(action)
		
	editor.action_manager.commit_action(actions)
	load_properties(editor, objects)

func change_property(property: String, new_value, check_matches, save_to_data):
	var affected_objects: Dictionary = setup_affected_objects(property, new_value)
	if check_matches and affected_objects["property_matches"] >= objects.size(): return
	affected_objects.erase("property_matches")
	print(affected_objects)
	if save_to_data:
		var action := ChangePropertyBulkAction.new()
		action.affected_objects = affected_objects
		action.bulk_store_original_properties()
		action.connect("done", self, "load_properties", [editor, objects])
		action.connect("undone", self, "load_properties", [editor, objects])
		editor.action_manager.commit_action([action])
	else:
		for object in affected_objects:
			var properties = affected_objects[object]["changed_properties"]
			for property in properties:
				object[property] = properties[property]
				object.emit_signal("property_changed", property, properties[property])

func added_new_event(event):
	change_property("events", objects.keys()[0].events + [event], false, true)
