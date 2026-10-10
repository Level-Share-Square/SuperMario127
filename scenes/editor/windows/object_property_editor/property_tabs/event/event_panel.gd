extends HBoxContainer
class_name EventPanel

onready var event_name = $"%EventName"
onready var edit_properties = $"%EditProperties"

var held_event: Event

func populate_name():
	if not is_instance_valid(held_event):
		event_name.text = "Invalid Event"
		return
		
	event_name.text = class_util.get_custom_class_name(held_event).capitalize()

func edit_properties():
	# Populate event variable editor
	pass
