extends State

class_name SlideStopState

func _ready():
	priority = 4
	disable_movement = true
	disable_animation = true
	override_rotation = true
	use_dive_collision = true

func _update(delta):
	var sprite = character.animated_sprite
	if abs(sprite.rotation_degrees) < 45:
		if (character.facing_direction == 1):
			sprite.animation = "idleRight"
		else:
			sprite.animation = "idleLeft"
	else:
		if (character.facing_direction == 1):
			sprite.animation = "diveRight"
		else:
			sprite.animation = "diveLeft"
		
	sprite.rotation = lerp(sprite.rotation, 0, delta * character.rotation_interpolation_speed)
	character.position.y -= 0.8
	character.velocity.y = 0
	
func _stop_check(_delta):
	var sprite = character.animated_sprite
	return sprite.rotation_degrees < 5 and sprite.rotation_degrees > -5

func _general_update(_delta):
	pass
