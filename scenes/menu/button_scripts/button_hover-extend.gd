extends ButtonSound

export var lerp_speed: float = 18
export var extend_amount: int = 4

var original_y: float
var focused: bool

func focus_entered(): focused = true
func focus_exited(): focused = false

func _init():
	original_y = rect_position.y
	
	#warning-ignore:return_value_discarded
	connect("focus_entered", self, "focus_entered")
	#warning-ignore:return_value_discarded
	connect("focus_exited", self, "focus_exited")

func _process(delta):
	if is_hovered() or focused:
		rect_position.y = lerp(rect_position.y, original_y - extend_amount, delta * lerp_speed)
	else:
		rect_position.y = lerp(rect_position.y, original_y, delta * lerp_speed)
