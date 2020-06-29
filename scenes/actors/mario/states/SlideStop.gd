extends State

class_name SlideStopState

func _ready():
	priority = 4
	disable_movement = true
	disable_animation = true
	disable_snap = false
	override_rotation = true

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
	character.position.y -= 1.5
		
func _stop(_delta):
	var collision = character.get_node("Collision")
	var dive_collision = character.get_node("CollisionDive")
	var ground_collision = character.get_node("GroundCollision")
	var left_collision = character.get_node("LeftCollision")
	var right_collision = character.get_node("RightCollision")
	var dive_ground_collision = character.get_node("GroundCollisionDive")
	collision.disabled = false
	ground_collision.disabled = false
	left_collision.disabled = false
	right_collision.disabled = false
	dive_collision.disabled = true
	dive_ground_collision.disabled = true
	
func _stop_check(_delta):
	var sprite = character.animated_sprite
	return sprite.rotation_degrees < 5 and sprite.rotation_degrees > -5

func _general_update(_delta):
	pass
