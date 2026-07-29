extends CollapsibleContainer

onready var wheel = $"%Wheel"
var active = false


func on_pressed():
	.on_pressed()

	if !active:
		wheel.update_value($Color.get_stylebox("panel").bg_color)
		var tween = get_tree().create_tween()
		tween.tween_property(owner, "self_modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_CUBIC)
		active = true
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(owner, "self_modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_CUBIC)
		tween.connect("finished", self, "tween_finished", [tween])
		active = false
		owner.change_property(wheel.base_color)


func tween_finished(tween):
	tween.kill()
