extends ButtonSound

export var lerp_speed: float = 12
export var target_scale: Vector2 = Vector2(1.025, 1.025)

var original_scale: Vector2
var focused: bool

func focus_entered(): focused = true
func focus_exited(): focused = false

func _ready():
	original_scale = rect_scale
	
	#warning-ignore:return_value_discarded
	connect("focus_entered", self, "focus_entered")
	#warning-ignore:return_value_discarded
	connect("focus_exited", self, "focus_exited")

var last_scale: Vector2
func _process(delta):
	if is_hovered() or focused:
		rect_scale = lerp(rect_scale, target_scale, delta * lerp_speed)
	else:
		rect_scale = lerp(rect_scale, original_scale, delta * lerp_speed)

	last_scale = rect_scale
