extends AnimatedSprite

onready var mario_sprite : AnimatedSprite = get_parent()

func _physics_process(_delta):
	animation = mario_sprite.animation
	frame = mario_sprite.frame
	flip_h = mario_sprite.flip_h
