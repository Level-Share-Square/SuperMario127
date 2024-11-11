extends ScrollContainer


const SNAP_THRESHOLD: float = 0.1
const LERP_THRESHOLD: float = 8.0
export var lerp_speed: float

var target_scroll: float = -1
var last_scroll: float


func _process(delta):
	if abs(last_scroll - scroll_vertical) > LERP_THRESHOLD:
		target_scroll = scroll_vertical
		scroll_vertical = last_scroll
	
	if target_scroll > -1:
		scroll_vertical = lerp(scroll_vertical, target_scroll, delta * lerp_speed)
		if abs(target_scroll - scroll_vertical) < SNAP_THRESHOLD:
			scroll_vertical = target_scroll
			target_scroll = -1
	
	last_scroll = scroll_vertical
	
