extends ProgressBar

const LERP_SPEED: float = 1.0
var real_value: float = 0

func _process(delta):
	if not is_visible_in_tree(): return
	value = lerp(value, real_value, delta * LERP_SPEED)
