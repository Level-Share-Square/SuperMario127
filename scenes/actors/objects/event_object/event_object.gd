extends GameObject
class_name EventObject

var events: Array = []

func _register_properties():
	register_property(4, "events", events, true)

func run_event():
	if events.size() == 0:
		print("Event queue finished!")
		return
	
	var event: Event = events.pop_front()
	event.connect("event_finished", self, "run_event")
	event.do_event(self)
