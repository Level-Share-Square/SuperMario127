tool
extends AnimatedSprite

onready var mario_sprite : AnimatedSprite = get_parent()

func _process(_delta):
	animation = mario_sprite.animation
	frame = mario_sprite.frame
	flip_h = mario_sprite.flip_h
	flip_v = mario_sprite.flip_v
	offset = mario_sprite.offset
