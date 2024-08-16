extends ButtonSound

export var lerp_speed: float = 12
export var sink_amount: int = 24
export var direction: int = -1

var original_x: float
var focused: bool
var force_hover: bool

func focus_entered(): focused = true
func focus_exited(): focused = false

func _ready():
	original_x = rect_position.x
	
	#warning-ignore:return_value_discarded
	connect("focus_entered", self, "focus_entered")
	#warning-ignore:return_value_discarded
	connect("focus_exited", self, "focus_exited")

var last_x: float
func _process(delta):
	## fixes jittering from ui force-repositioning control nodes
	if abs(last_x - rect_position.x) > sink_amount/2:
		rect_position.x = last_x
	
	if is_hovered() or focused or force_hover:
		rect_position.x = lerp(rect_position.x, original_x, delta * lerp_speed)
	else:
		rect_position.x = lerp(rect_position.x, original_x + (sink_amount * direction), delta * lerp_speed)
	
	last_x = rect_position.x
