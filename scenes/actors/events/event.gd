extends Resource
class_name Event

const COLOR_OPENING: String = "[color=#7dcbff]"
const COLOR_CLOSING: String = "[/color]"

signal event_finished

func get_internal_name() -> String:
	return "Please override get_internal_name()!"

func get_display_name() -> String:
	return "Unset"

func get_display_suffix() -> String:
	return " (pls report)"

func get_display_text() -> String:
	return get_display_name() + get_display_suffix() 

func do_event(handler: Node):
	emit_signal("event_finished")

func check_equivalent(other_event: Event) -> bool:
	if class_util.get_custom_class_name(other_event) != class_util.get_custom_class_name(self): return false

	var properties: Dictionary = self.properties
	for property in properties:
		if property == "event": continue
		if other_event.properties[property] != properties[property]: return false
		
	return true
	
func duplicate_deep() -> Event:
	var new_event = class_util.create_instance_from_name(class_util.get_custom_class_name(self))
	new_event.properties = self.properties.duplicate(true)
	new_event.properties.erase("event")
	return new_event
