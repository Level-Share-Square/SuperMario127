extends Event
class_name WaitEvent

var properties: Dictionary = {
	"time": 4
}

func do_event(handler: Node):
	yield(handler.get_tree().create_timer(properties["time"]), "timeout")
	
	.do_event(handler)
