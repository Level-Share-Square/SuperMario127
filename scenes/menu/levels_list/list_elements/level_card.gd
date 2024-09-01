extends ButtonHoverRotate

signal drag_started(card)
signal drag_ended(card)
signal button_pressed

const DRAG_HOLD_TIME = 0.125

var mouse_down: bool
var hold_time: float


func _process(delta):
	if mouse_down and hold_time < DRAG_HOLD_TIME:
		hold_time += delta
		if hold_time >= DRAG_HOLD_TIME:
			emit_signal("drag_started", self)


func button_down():
	mouse_down = true
	hold_time = 0


func button_up():
	mouse_down = false
	if hold_time >= DRAG_HOLD_TIME:
		emit_signal("drag_ended", self)
	else:
		emit_signal("button_pressed")
