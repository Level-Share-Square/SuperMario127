tool
extends AnimatedSprite

onready var mario_front = $"%MarioFront"

func _process(_delta):
	if not is_visible_in_tree(): return
	animation = mario_front.animation
	frame = mario_front.frame
	playing = mario_front.playing
	position = mario_front.position
	scale = mario_front.scale
	offset = mario_front.offset
	modulate = mario_front.modulate
