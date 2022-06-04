extends State

class_name SlideStopState

func _ready():
	priority = 4
	disable_movement = true
	disable_animation = true
	override_rotation = true

func _start(_delta):
	character.sprite.position.y = 6

func _update(delta):
	var sprite = character.sprite
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
	
	sprite.rotation = lerp(sprite.rotation, 0, fps_util.PHYSICS_DELTA * character.rotation_interpolation_speed)
	sprite.position.y -= 0.4
	if sprite.position.y < 0:
		sprite.position.y = 0

func _stop_check(_delta):
	var sprite = character.sprite
	return sprite.rotation_degrees < 5 and sprite.rotation_degrees > -5

func _general_update(_delta):
	pass
