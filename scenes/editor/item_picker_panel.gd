extends PanelContainer

const TRANS_SPEED: float = 0.4

onready var container: Control = get_parent()
onready var tween = $Tween
onready var hide_margin: float = container.margin_left
var is_shown: bool = false

func toggle():
	is_shown = not is_shown
	if is_shown:
		tween.stop_all()
		tween.interpolate_property(
			container, "margin_left", 
			container.margin_left, 0, TRANS_SPEED, 
			Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.start()
	else:
		tween.stop_all()
		tween.interpolate_property(
			container, "margin_left", 
			container.margin_left, hide_margin, TRANS_SPEED, 
			Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.start()
