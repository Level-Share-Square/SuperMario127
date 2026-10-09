extends ButtonSound
class_name ButtonHoverRotate

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
	if abs(last_rot - rect_rotation) > rotation_amount/4:
		rect_rotation = last_rot
	
	## framerate independent
	var interp_amount: float = 1 - exp(-lerp_speed * delta)
	if is_hovered() or focused:
		rect_rotation = lerp(rect_rotation, rotation_amount, interp_amount)
	else:
		rect_rotation = lerp(rect_rotation, 0, interp_amount)
	
	last_rot = rect_rotation
