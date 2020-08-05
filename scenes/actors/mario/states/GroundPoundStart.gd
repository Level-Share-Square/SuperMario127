extends State

class_name GroundPoundStartState

var wait_timer = 0
export var dive_vertical_power = 350
var can_dive = true

func _ready():
	priority = 4
	disable_turning = true
	disable_movement = true
	disable_animation = true
	override_rotation = true
	blacklisted_states = ["SlideState", "SlideStopState", "GroundPoundState", "GroundPoundEndState"]

func _start_check(_delta):
	return character.inputs[5][1] and !character.is_grounded() and !character.test_move(character.transform, Vector2(0, 24))

func _start(_delta):
	if character.last_state == character.get_state_node("DiveState"):
		can_dive = false
	else:
		can_dive = true
	character.sprite.rotation_degrees = 0
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
	if character.inputs[character.input_names.dive][1] and can_dive:
		character.velocity.y = -dive_vertical_power
		character.set_state_by_name("DiveState", delta)
		
func _stop(delta):
	var sprite = character.sprite
	sprite.rotation_degrees = 0
	if wait_timer <= 0:
		character.set_state_by_name("GroundPoundState", delta)
		character.get_state_node("GroundPoundState").can_dive = can_dive

func _stop_check(_delta):
	return wait_timer <= 0

func _general_update(delta):
	if wait_timer > 0:
		wait_timer -= delta
		if wait_timer <= 0:
			wait_timer = 0
