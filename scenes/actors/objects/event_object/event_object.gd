extends GameObject
class_name EventTrigger

var events: Array = []
var current_event_index: int = 0

func _register_properties():
	register_property(4, "events", events, false)
	property_tabs.append("event")
	
func _ready():
	set_object_data(object_data)
	current_event_index = 0
	for i in range(events.size()):
		if events[i]:
			events[i] = events[i].duplicate_deep()

func run_event():
	if current_event_index == events.size():
		print("Event queue finished!")
		return
	
	var event: Event = events[current_event_index]
	print("Running event: ", event.get_internal_name())
	event.connect("event_finished", self, "run_event")
	event.do_event(self)
	current_event_index += 1
