extends Event
class_name WaitEvent

var properties: Dictionary = {
	"time": 4
}

var property_overrides: Dictionary = {}

func get_internal_name() -> String:
	return "wait_event"

func get_display_name() -> String:
	return "Wait"

func get_display_suffix() -> String:
	var suffix: String = " col_open%scol_close second"
	suffix = suffix.replace("col_open", COLOR_OPENING)
	suffix = suffix.replace("col_close", COLOR_CLOSING)
	suffix = suffix % properties["time"]
	suffix += "s" if properties["time"] > 1 else ""
	return suffix

func do_event(handler: Node):
	yield(handler.get_tree().create_timer(properties["time"]), "timeout")
	
	.do_event(handler)
