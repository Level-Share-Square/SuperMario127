extends Button



func _ready():
	connect("pressed", self, "_button_pressed")

func _button_pressed():
	var parent = get_parent()
	parent.button_pressed = true
	var animplayer = get_parent().get_node("AnimationPlayer")
	animplayer.play("buttonFadeOut")
