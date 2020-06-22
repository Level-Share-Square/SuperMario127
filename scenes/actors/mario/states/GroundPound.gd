extends State

class_name GroundPoundState

export var ground_pound_power := 550

func _ready():
	priority = 4
	disable_turning = true
	disable_animation = true
	blacklisted_states = []

func _start_check(_delta):
	return false

func _start(_delta):
	var sprite = character.sprite
	if character.facing_direction == 1:
		sprite.animation = "groundPoundRight"
	else:
		sprite.animation = "groundPoundLeft"
	character.velocity.y = ground_pound_power
	character.attacking = true
	character.big_attack = true

func _update(_delta):
	character.attacking = true
	character.big_attack = true
	character.heavy = true

func _stop(delta):
	if character.is_grounded():
		var normal = character.ground_check.get_collision_normal()
		if normal.x == 0:
			character.set_state_by_name("GroundPoundEndState", delta)
		else:
			var move_direction = 1
			if normal.x < 0:
				move_direction = -1
			character.velocity.x = 376 * move_direction
			character.velocity.y = 150
			character.position.y += 6
			character.set_state_by_name("ButtSlideState", delta)
	else:
		character.jump_animation = 0
		character.velocity.y = character.velocity.y / 4
		character.attacking = false
		character.big_attack = false
		character.heavy = false

func _stop_check(_delta):
	return character.is_grounded() or character.inputs[6][1]
