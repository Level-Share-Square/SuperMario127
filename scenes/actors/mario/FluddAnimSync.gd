tool
extends AnimatedSprite

onready var mario_sprite : AnimatedSprite = get_parent()
var lag_behind: bool = false
var lag_amount: float = 1
var last_sprite_pos

func _process(_delta):
	if not mario_sprite: return
	
	animation = mario_sprite.animation
	frame = mario_sprite.frame
	flip_h = mario_sprite.flip_h
	flip_v = mario_sprite.flip_v
	offset = mario_sprite.offset
	
	if lag_behind:
		if last_sprite_pos and last_sprite_pos != mario_sprite.global_position:
			global_position = mario_sprite.global_position - (mario_sprite.global_position - last_sprite_pos)*lag_amount
			global_rotation = mario_sprite.global_rotation
		last_sprite_pos = mario_sprite.global_position
