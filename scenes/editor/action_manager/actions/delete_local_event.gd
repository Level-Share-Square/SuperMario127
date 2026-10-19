extends BaseLocalEventAction
class_name DeleteLocalEventAction

signal done
signal undone

func _do():
	object.set_property("events", sub_event(object.events, event), true)
	emit_signal("done")
	
func _undo():
	object.set_property("events", add_event_at(object.events, event, event_index), true)
	emit_signal("undone")

func sub_event(events: Array, event: Event) -> Array:
	var new_events = events.duplicate()
	new_events.erase(event)
	return new_events
	
func add_event_at(events: Array, event: Event, pos: int) -> Array:
	var new_events = events.duplicate()
	new_events.insert(pos, event)
	return new_events
