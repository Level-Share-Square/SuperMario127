extends ButtonSound

onready var tween = $Tween
onready var tween_hover = $TweenHover

onready var icon_offset = $"%IconOffset"
onready var icon_node = $"%Icon"

var item: PlaceableItem

func _process(delta):
	if item != null:
		icon_node.texture = item.icons[0]

func button_down():
	tween.stop_all()
	tween.interpolate_property(icon_node, "rect_position:y",
		icon_node.rect_position.y, -3, 0.075,
		Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.start()

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
