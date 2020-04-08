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

func _stop(delta):
	character.attacking = false
	character.big_attack = false
	if character.is_grounded():
		character.set_state_by_name("GroundPoundEndState", delta)
	else:
		character.jump_animation = 0
		character.velocity.y = character.velocity.y / 4

func _stop_check(_delta):
	return character.is_grounded() or character.gp_cancel_just_pressed
