extends State

class_name DiveState

export var dive_power: Vector2 = Vector2(1350, 75)

func _start_check(delta):
	return Input.is_action_just_pressed("dive") and !character.is_grounded() and !character.is_walled()

func _start(delta):
	var dive_player = character.get_node("DiveSoundPlayer")
	character.velocity.x = character.velocity.x - (character.velocity.x - (dive_power.x * character.facing_direction)) / 5
	character.velocity.y += dive_power.y
	character.old_friction = character.friction
	character.rotating = true
	dive_player.play()

func _update(delta):
	var sprite = character.get_node("AnimatedSprite")
	if (!character.is_grounded()):
		character.friction = character.old_friction
	if (character.facing_direction == 1):
		sprite.animation = "diveRight"
	else:
		sprite.animation = "diveLeft"
		
func _stop(delta):
	character.set_state_by_name("Slide", delta)

func _stop_check(delta):
	return character.is_grounded()
