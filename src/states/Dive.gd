extends State

class_name DiveState

export var dive_power: Vector2 = Vector2(1350, 75)
export var bonk_power: float = 150
export var maxVelocityX: float = 700
var last_above_rot_limit = false

func _start_check(delta):
	return Input.is_action_pressed("dive") and character.state != character.get_state_instance("Slide") and !character.is_grounded() and !character.is_walled() and character.state != character.get_state_instance("Bonked")

func _start(delta):
	var dive_player = character.get_node("DiveSoundPlayer")
	character.velocity.x = character.velocity.x - (character.velocity.x - (dive_power.x * character.facing_direction)) / 5
	character.velocity.y += dive_power.y
	character.rotating = true
	dive_player.play()
	if abs(character.velocity.x) > maxVelocityX:
		character.velocity.x = maxVelocityX * character.facing_direction
	character.jump_animation = 0
	character.current_jump = 0

func _update(delta):
	var sprite = character.get_node("AnimatedSprite")
	if (!character.is_grounded()):
		character.friction = character.real_friction
	if (character.facing_direction == 1):
		sprite.animation = "diveRight"
	else:
		sprite.animation = "diveLeft"
	var new_angle = ((character.velocity.y / 7) * character.facing_direction) + (90 * character.facing_direction)
	if (abs(new_angle) < 185):
		sprite.rotation_degrees = new_angle
		last_above_rot_limit = false
	else:
		if (!last_above_rot_limit):
			sprite.rotation_degrees = 185
		sprite.rotation_degrees += 0.35
		last_above_rot_limit = true
		
func _stop(delta):
	var sprite = character.get_node("AnimatedSprite")
	sprite.rotation_degrees = 0
	if character.is_grounded():
		character.set_state_by_name("Slide", delta)
	if character.is_walled():
		character.velocity.x = bonk_power * -character.facing_direction 
		character.position.x -= 2 * character.facing_direction
		character.set_state_by_name("Bonked", delta)

func _stop_check(delta):
	return character.is_grounded() or (character.is_walled_right() && character.facing_direction == 1) or (character.is_walled_left() && character.facing_direction == -1)
