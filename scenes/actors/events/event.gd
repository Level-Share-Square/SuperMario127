extends Resource
class_name Event

signal event_finished

func do_event(handler: Node):
	emit_signal("event_finished")
