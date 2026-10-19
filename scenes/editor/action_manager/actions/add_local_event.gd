extends BaseLocalEventAction
class_name AddLocalEventAction

signal done
signal undone

func _do():
	old_events = object.events.duplicate(true)
	object.set_property("events", object.events + [event], true)
	emit_signal("done")
	
func _undo():
	object.set_property("events", old_events, true)
	emit_signal("undone")
