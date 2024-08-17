extends ButtonSound

export var rotation_amount: float = 5
export var lerp_speed: float = 12

var focused: bool

func focus_entered(): focused = true
func focus_exited(): focused = false

func _ready():
	#warning-ignore:return_value_discarded
	connect("focus_entered", self, "focus_entered")
	#warning-ignore:return_value_discarded
	connect("focus_exited", self, "focus_exited")

var last_rot: float
func _process(delta):
	## fixes jittering from ui force-repositioning control nodes
	if abs(last_rot - rect_rotation) > rotation_amount/2:
		rect_rotation = last_rot
	
	if is_hovered() or focused:
		rect_rotation = lerp(rect_rotation, rotation_amount, delta * lerp_speed)
	else:
		rect_rotation = lerp(rect_rotation, 0, delta * lerp_speed)
	
	last_rot = rect_rotation
