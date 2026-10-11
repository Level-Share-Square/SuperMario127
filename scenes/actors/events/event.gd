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
