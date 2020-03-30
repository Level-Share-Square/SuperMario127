extends State

class_name GroundPoundStartState

var wait_timer = 0

func _ready():
	priority = 4
	disable_turning = true
	disable_movement = true
	disable_animation = true
	blacklisted_states = ["DiveState"]

func _start_check(delta):
	return Input.is_action_just_pressed("ground_pound") and !character.is_grounded()

func _start(delta):
	wait_timer = 0.35

func _update(delta):
	var sprite = character.sprite
	character.velocity = Vector2(0, 0)
	if character.facing_direction == 1:
		sprite.animation = "tripleJumpRight"
	else:
		sprite.animation = "tripleJumpLeft"
	sprite.rotation_degrees = lerp(abs(sprite.rotation_degrees), 360, 12 * delta) * character.facing_direction
		
func _stop(delta):
	var sprite = character.sprite
	sprite.rotation_degrees = 0
	character.set_state_by_name("GroundPoundState", delta)

func _stop_check(delta):
	return wait_timer <= 0

func _general_update(delta):
	if wait_timer > 0:
		wait_timer -= delta
		if wait_timer <= 0:
			wait_timer = 0
