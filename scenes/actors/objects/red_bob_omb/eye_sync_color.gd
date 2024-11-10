extends AnimatedSprite

onready var mario_sprite : AnimatedSprite = get_parent()
onready var head_color = get_parent().get_node("HeadColor")

func _process(delta):
	animation = mario_sprite.animation
	frame = mario_sprite.frame
	flip_h = mario_sprite.flip_h
	offset = mario_sprite.offset
	
#	if head_color.modulate < 0.75:
#		modulate = Color(1, 1, 1, 1)
#	else:
#		modulate = Color(0, 0, 0, 1)
