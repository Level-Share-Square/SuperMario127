extends State

class_name GroundPoundStartState

var wait_timer = 0

func _ready():
	priority = 4
	disable_turning = true
	disable_movement = true
	disable_animation = true
	override_rotation = true
	blacklisted_states = ["DiveState", "SlideState", "SlideStopState", "GroundPoundState", "GroundPoundEndState", "BackflipState"]

func _start_check(_delta):
	return character.inputs[5][1] and !character.is_grounded() and !character.test_move(character.transform, Vector2(0, 24))

func _start(_delta):
	wait_timer = 0.35
	character.sound_player.play_gp_windup_sound()

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

func _stop_check(_delta):
	return wait_timer <= 0

func _general_update(delta):
	if wait_timer > 0:
		wait_timer -= delta
		if wait_timer <= 0:
			wait_timer = 0
