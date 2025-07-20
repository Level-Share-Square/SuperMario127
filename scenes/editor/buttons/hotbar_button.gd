extends ButtonSound

onready var tween = $Tween
onready var tween_hover = $TweenHover

onready var icon_offset = $"%IconOffset"
onready var icon_node = $"%Icon"

onready var hotbar = $"%Hotbar"


var item: PlaceableItem
var held: bool = false
var favorite_wait_timer: float = 2.0

func _process(delta):
	if item != null:
		icon_node.texture = item.icons[0]
	if held:
		yield(get_tree().create_timer(favorite_wait_timer), "timeout")
		if held:
			hotbar.new_favorite_selected(item)
			held = false

func button_down():
	held = true
	tween.stop_all()
	tween.interpolate_property(icon_node, "rect_position:y",
		icon_node.rect_position.y, -3, 0.075,
		Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.start()

func button_up():
	held = false
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
