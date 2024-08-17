extends "res://scenes/menu/button_scripts/button_hover-vertical.gd"

func _ready():
	connect("pressed", self, "_button_pressed")

func _button_pressed():
	var parent = get_parent()
	parent.button_pressed = true
	var animplayer = get_parent().get_node("AnimationPlayer")
	animplayer.play("buttonFadeOut")
	if Singleton2.mod_active:
		var res = get_parent().get_node("ResetMod")
		res.show()
		var tween = Tween.new()
		add_child(tween)
		tween.interpolate_property(res, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1, Tween.EASE_IN)
		tween.start()
