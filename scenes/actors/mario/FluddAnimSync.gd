extends AnimatedSprite

onready var mario_sprite : AnimatedSprite = get_parent()

func _physics_process(_delta):
	animation = mario_sprite.animation
	frame = mario_sprite.frame
