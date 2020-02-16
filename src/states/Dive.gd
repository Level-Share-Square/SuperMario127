extends State

class_name DiveState

export var divePower: Vector2 = Vector2(1350, 75)
export var maxVelocityX: float = 700
var last_above_rot_limit = false

func _startCheck(delta):
	return Input.is_action_pressed("dive") and character.state != character.get_state_instance("Slide")  and !character.is_grounded() and !character.is_walled()

func _start(delta):
	var dive_player = character.get_node("DiveSoundPlayer")
	character.velocity.x = character.velocity.x - (character.velocity.x - (divePower.x * character.facing_direction)) / 5
	character.velocity.y += divePower.y
	character.oldFriction = character.friction
	character.rotating = true
	dive_player.play()
	if abs(character.velocity.x) > maxVelocityX:
		character.velocity.x = maxVelocityX * character.facing_direction

func _update(delta):
	var sprite = character.get_node("AnimatedSprite")
	if (!character.is_grounded()):
		character.friction = character.oldFriction
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
	if (character.is_grounded()):
		character.set_state_by_name("Slide", delta)

func _stopCheck(delta):
	return character.is_grounded()
