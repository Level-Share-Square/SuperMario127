extends State

class_name RainbowStarWindupState

var time_charging = 0.0

func _ready():
	priority = 10
	blacklisted_states = []
	disable_movement = true
	disable_turning = true
	disable_friction = true
	disable_animation = true
	override_rotation = true

func _start_check(_delta):
	return character.inputs[4][1] and (character.is_grounded() and character.rainbow_stored)

func _start(delta):
	time_charging = 0.0
	if character.facing_direction == 1:
		character.sprite.play("movingRight", true)
	else:
		character.sprite.play("movingLeft", true)

func _update(delta):
	if time_charging < 1.5:
		time_charging += delta
		if time_charging >= 1.5:
			time_charging = 1.5
	character.velocity.x = (35 * (1 - (time_charging/1.5))) * -character.facing_direction
	character.sprite.speed_scale = 0.5 * (1 - (time_charging / 1.5))

func _stop(delta):
	if time_charging > 0.75:
		character.rainbow_stored = false
		character.set_powerup(character.get_powerup_node("RainbowPowerup"))
		character.set_state_by_name("RainbowStarState", delta)

func _stop_check(delta):
	return !character.inputs[4][0]
