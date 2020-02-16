extends State

class_name DiveState

export var divePower: Vector2 = Vector2(1350, 75)

func _startCheck(delta):
	return Input.is_action_just_pressed("dive") and !character.is_grounded() and !character.is_walled()

func _start(delta):
	var dive_player = character.get_node("DiveSoundPlayer")
	character.velocity.x = character.velocity.x - (character.velocity.x - (divePower.x * character.facing_direction)) / 5
	character.velocity.y += divePower.y
	character.oldFriction = character.friction
	character.rotating = true
	dive_player.play()

func _update(delta):
	var sprite = character.get_node("AnimatedSprite")
	if (!character.is_grounded()):
		character.friction = character.oldFriction
	if (character.facing_direction == 1):
		sprite.animation = "diveRight"
	else:
		sprite.animation = "diveLeft"
		
func _stop(delta):
	character.set_state_by_name("Slide", delta)

func _stopCheck(delta):
	return character.is_grounded()
