extends State

class_name GetupState

export var get_up_power = 320

var stop_counter = 0.0

func _ready():
	priority = 1
	disable_turning = true
	
func _start(delta):
	var sprite = character.animated_sprite
	character.velocity.y = -get_up_power
	character.position.y -= 1
	character.friction = character.real_friction
	sprite.rotation_degrees = 90 * character.facing_direction
	stop_counter += delta
	sprite.rotation_degrees = 1
	
func _update(delta):
	var sprite = character.animated_sprite
	if sprite.rotation_degrees < 365 and sprite.rotation_degrees != 0:
		if (character.facing_direction == 1):
			sprite.animation = "tripleJumpRight"
		else:
			sprite.animation = "tripleJumpLeft"
		sprite.rotation_degrees = lerp(abs(sprite.rotation_degrees), 380, 8 * delta) * character.facing_direction
	else:
		if (character.facing_direction == 1):
			sprite.animation = "jumpRight"
		else:
			sprite.animation = "jumpLeft"
		sprite.rotation_degrees = 0
	stop_counter += delta

func _stop(delta):
	var sprite = character.animated_sprite
	sprite.rotation_degrees = 0
	stop_counter = 0

func _stop_check(delta):
	return stop_counter > 0.5 or character.is_grounded()
