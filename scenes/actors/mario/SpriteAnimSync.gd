tool
extends AnimatedSprite

onready var parent_sprite : AnimatedSprite = get_parent()
var lag_behind: bool = false
var lag_amount: float = 1
var last_sprite_pos

func _process(_delta):
	if not parent_sprite: return
	if not frames.has_animation(parent_sprite.animation): return
	
	animation = parent_sprite.animation
	frame = parent_sprite.frame
	flip_h = parent_sprite.flip_h
	flip_v = parent_sprite.flip_v
	offset = parent_sprite.offset
	
	if lag_behind:
		if last_sprite_pos and last_sprite_pos != parent_sprite.global_position:
			global_position = parent_sprite.global_position - (parent_sprite.global_position - last_sprite_pos)*lag_amount
			global_rotation = parent_sprite.global_rotation
		last_sprite_pos = parent_sprite.global_position
