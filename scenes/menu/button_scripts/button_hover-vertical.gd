extends ButtonSound

export var lerp_speed: float = 18
export var extend_amount: int = 4

var original_y: float
var focused: bool

func focus_entered(): focused = true
func focus_exited(): focused = false

func _ready():
	original_y = rect_position.y
	
	#warning-ignore:return_value_discarded
	connect("focus_entered", self, "focus_entered")
	#warning-ignore:return_value_discarded
	connect("focus_exited", self, "focus_exited")

var last_y: float
func _process(delta):
	## fixes jittering from ui force-repositioning control nodes
	if abs(last_y - rect_position.y) > extend_amount/2:
		rect_position.y = last_y
	
	if is_hovered() or focused:
		rect_position.y = lerp(rect_position.y, original_y - extend_amount, delta * lerp_speed)
	else:
		rect_position.y = lerp(rect_position.y, original_y, delta * lerp_speed)

	last_y = rect_position.y
