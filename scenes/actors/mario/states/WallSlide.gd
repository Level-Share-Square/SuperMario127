extends State

class_name WallSlideState

export var gravity_scale: float = 0.5
var old_gravity_scale = 1
var wall_buffer = 0.0

func _ready():
	priority = 1

func _start_check(delta):
	return ((character.is_walled_right() and (character.move_direction == 1 or character.is_wj_chained)) or (character.is_walled_left() and (character.move_direction == -1 or character.is_wj_chained))) and !character.is_grounded() and (character.velocity.y > 0 or character.is_wj_chained) and character.jump_animation != 2

func _start(delta):
	character.velocity.y = character.velocity.y/3
	if character.is_walled_right():
		character.direction_on_stick = 1
	else:
		character.direction_on_stick = -1
	wall_buffer = 0.075
	old_gravity_scale = character.gravity_scale
	character.gravity_scale = gravity_scale
	pass

func _update(delta):
	character.velocity.x += character.direction_on_stick * 5
	if !(character.is_walled()):
		wall_buffer -= delta
		if wall_buffer <= 0:
			wall_buffer = 0
	else:
		var sprite = character.animated_sprite
		if character.direction_on_stick == 1:
			sprite.animation = "wallSlideRight"
		else:
			sprite.animation = "wallSlideLeft"
		wall_buffer = 0.075
	if character.is_ceiling():
		character.velocity.y = 3
	if character.velocity.y < 0:
		character.gravity_scale = old_gravity_scale
	else:
		character.gravity_scale = gravity_scale

func _stop(delta):
	character.gravity_scale = old_gravity_scale
	wall_buffer = 0
	pass

func _stop_check(delta):
	return wall_buffer <= 0 or character.is_grounded()
