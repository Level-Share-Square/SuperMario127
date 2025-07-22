extends ButtonSound

const FAVORITE_COLOR: Color = Color(0.5, 1, 1)
const WAIT_TIMER: float = 1.0

onready var tween = $Tween
onready var tween_hover = $TweenHover
onready var tween_progress = $TweenProgress

onready var icon_offset = $"%IconOffset"
onready var icon_node = $"%Icon"
onready var progress = $"%Progress"

onready var hotbar = $"%Hotbar"

var item: PlaceableItem
var favorite = false
var palette = 0

func button_down():
	tween.stop_all()
	tween.interpolate_property(icon_node, "rect_position:y",
		icon_node.rect_position.y, -3, 0.075,
		Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.start()
	
	var default_color: Color = Color.white if not favorite else FAVORITE_COLOR
	var target_color: Color = FAVORITE_COLOR if not favorite else Color.white
	
	tween_progress.interpolate_property(self, "self_modulate",
		self_modulate, target_color, WAIT_TIMER,
		Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	tween_progress.start()
	hotbar.palette_selected(get_index())

func button_up():
	tween.stop_all()
	tween.interpolate_property(icon_node, "rect_position:y",
		icon_node.rect_position.y, 1, 0.15,
		Tween.TRANS_BOUNCE, Tween.EASE_IN)
	tween.start()
	
func mouse_entered():
	tween_hover.stop_all()
	tween_hover.interpolate_property(icon_offset, "rect_position:y",
		icon_offset.rect_position.y, -1, 0.075,
		Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween_hover.start()

func mouse_exited():
	tween_hover.stop_all()
	tween_hover.interpolate_property(icon_offset, "rect_position:y",
		icon_offset.rect_position.y, 0, 0.075,
		Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween_hover.start()
