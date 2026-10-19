extends HBoxContainer
class_name EventPanel

onready var sizing = $"%Sizing"
onready var event_name = $"%EventName"
onready var use_event = $"%UseEvent"
onready var edit_properties = $"%EditProperties"

var held_event: Event
var is_list_event: bool

signal event_picked
signal open_properties

func populate_name():
	if not is_instance_valid(held_event):
		event_name.text = "Invalid (please report!)"
		return
	
	if is_list_event:
		event_name.bbcode_text = "[center]%s[/center]" % held_event.get_display_name()
		use_event.show()
		edit_properties.hide()
		use_event.connect("pressed", self, "emit_signal", ["event_picked"])
	else:
		event_name.bbcode_text = "[center]%s[/center]" % held_event.get_display_text()
		use_event.hide()
		edit_properties.show()
		edit_properties.connect("pressed", self, "edit_properties")
	
	sizing.text = " %s " % event_name.text

func edit_properties():
	# Populate event variable editor
	emit_signal("open_properties")
