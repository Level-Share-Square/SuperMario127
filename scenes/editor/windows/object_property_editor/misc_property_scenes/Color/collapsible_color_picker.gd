extends CollapsibleContainer

onready var wheel = $"%Wheel"
onready var color_manager = $"%Expanded"
var active = false

func on_pressed():
	.on_pressed()

	if !active:
		var tween = get_tree().create_tween()
		tween.tween_property(owner, "self_modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_CUBIC)
		active = true
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(owner, "self_modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_CUBIC)
		active = false


func collapse():
	active = true
	on_pressed()
