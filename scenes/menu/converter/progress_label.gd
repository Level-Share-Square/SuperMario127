extends Label

const LERP_SPEED: float = 0.5

onready var progress_bar = $"%ProgressBar"
var auto_update: bool = true
var internal_value: float = 0

func _process(delta):
	if not auto_update: return
	if not is_visible_in_tree(): return
	if not is_instance_valid(progress_bar): return
	internal_value = lerp(internal_value, progress_bar.value, delta * LERP_SPEED)
	text = str(stepify(internal_value / progress_bar.max_value, 0.0001) * 100).pad_decimals(2) + "%"
