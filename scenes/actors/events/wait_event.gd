extends Event
class_name WaitEvent

var time: float = 0

func do_event(handler: Node):
	yield(handler.get_tree().create_timer(time), "timeout")
	
	.do_event(handler)
