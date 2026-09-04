extends State

class_name JumpState

const JUMP_SQUISH := Vector2(0.85, 1.15)
const FAST_LERP: float = 0.09
const SLOW_LERP: float = 0.04

export var jump_power: float = 350
export var double_jump_power: float = 425
export var triple_jump_power: float = 495

export var jump_power_luigi: float = 350
export var double_jump_power_luigi: float = 425
export var triple_jump_power_luigi: float = 495

var ground_buffer = 0
var jump_buffer = 0
var ledge_buffer = 0
var dive_buffer = 0
var jump_playing = false
var last_grounded = false
var squish_lerp = false
var override = false
var direction_on_tj = 1
var lerp_speed: float = SLOW_LERP


## jump height variation
var jump_released: bool = false
const HEIGHT_MULT: float = 0.7


func _ready():
	priority = 1
	blacklisted_states = ["BounceState", "DiveState", "SlideState", "GetupState", "BackflipState"]
	
func lerp(a, b, t):
	return (1 - t) * a + t * b

func _start_check(_delta):
	return ledge_buffer > 0 and (jump_buffer > 0 or (dive_buffer > 0 and abs(character.velocity.x) > 50 and !character.test_move(character.transform, Vector2(8 * character.facing_direction, 0))))

func _start(delta):
	## jump height variation
	lerp_speed = SLOW_LERP
	squish_lerp = true
	jump_released = false
	
	character.dust_jump_particles.restart()
	character.dust_jump_particles.emitting = true
	character.dust_jump_particles.process_material.direction = Vector3(-character.velocity.x/800, 1, 0)
	character.sprite.scale = JUMP_SQUISH
	var sprite = character.sprite
	var sound_player = character.sound_player
	jump_buffer = 0
	ground_buffer = 0
	jump_playing = true
	if ledge_buffer > 0:
		LastInputDevice.rumble(0.5, 0.0, 0.05)
		if dive_buffer > 0:
			character.current_jump = 0
		if character.current_jump == 2 and abs(character.velocity.x) < 80:
			character.current_jump = 1
		if character.current_jump != 2 and character.last_state == character.get_state_node("SpinningState"):
			character.set_state_by_name("SpinningState", delta)
		if character.current_jump == 0:
			if !dive_buffer > 0:
				sound_player.play_jump_sound()
				sound_player.play_jump_step_sound()
			if character.character == 0:
				character.velocity.y = -jump_power
			else:
				character.velocity.y = -jump_power_luigi
			character.position.y -= 3
			character.jump_animation = 0
			character.current_jump = 1
		elif character.current_jump == 1:
			sound_player.play_double_jump_sound()
			sound_player.play_jump_step_sound()
			if character.character == 0:
				character.velocity.y = -double_jump_power
			else:
				character.velocity.y = -double_jump_power_luigi
			character.position.y -= 3
			character.jump_animation = 1
			character.current_jump = 2
		elif character.current_jump == 2:
			sound_player.play_triple_jump_sound()
			sound_player.play_jump_step_sound()
			if character.character == 0:
				character.velocity.y = -triple_jump_power
			else:
				character.velocity.y = -triple_jump_power_luigi
			character.position.y -= 3
			character.jump_animation = 2
			character.current_jump = 0
			direction_on_tj = character.facing_direction
			sprite.rotation_degrees = direction_on_tj
	else:
		character.jump_animation = 0
	ledge_buffer = 0

func _update(_delta):
	var sprite = character.sprite
	if override and character.rotating_jump:
		if character.rotating_jump:
			sprite.animation="tripleJumpRight"
		if abs(sprite.rotation_degrees) > 360 or character.is_grounded():
			override = false

	elif jump_playing and character.velocity.y < 0 and !character.is_grounded():
		if character.facing_direction == 1:
			if character.jump_animation == 0:
				sprite.animation = "jumpRight"
			elif character.jump_animation == 1:
				sprite.animation = "doubleJumpRight"
			else:
				if direction_on_tj == 1:
					sprite.animation = "tripleJumpRight"
				else:
					sprite.animation = "tripleJumpLeft"
				character.rotating_jump = true
		elif character.facing_direction == -1:
			if character.jump_animation == 0:
				sprite.animation = "jumpLeft"
			elif character.jump_animation == 1:
				sprite.animation = "doubleJumpLeft"
			else:
				if direction_on_tj == 1:
					sprite.animation = "tripleJumpRight"
				else:
					sprite.animation = "tripleJumpLeft"
				character.rotating_jump = true
	else:
		jump_playing = false
	
	## jump height variation
	if not jump_released and not character.inputs[2][0] and dive_buffer <= 0:
		jump_released = true
		lerp_speed = FAST_LERP
		character.velocity.y *= HEIGHT_MULT


func _stop_check(_delta):
	if(!override):
		return character.velocity.y > 0

func _general_update(delta):
	if squish_lerp == true:
		character.sprite.scale = lerp(character.sprite.scale, Vector2(1, 1), lerp_speed)
	if character.is_grounded():
		squish_lerp = false
	var sprite = character.sprite
	if character.rotating_jump:
		if character.velocity.y > 0:
			character.jump_animation = 0
		if (character.state != null and character.state != character.get_state_node("JumpState") and character.state != character.get_state_node("FallState") and character.rotating_jump) or character.is_grounded() or abs(sprite.rotation_degrees) > 360 or character.controllable == false:
			character.rotating_jump = false
			sprite.rotation_degrees = 0
			character.jump_animation = 0
		else:
			sprite.rotation_degrees = lerp(abs(sprite.rotation_degrees), 380, 4 * delta) * direction_on_tj
	if character.is_grounded() and !last_grounded:
		ground_buffer = 0.175
	elif character.is_grounded():
		ledge_buffer = 0.125
	if ground_buffer > 0:
		ground_buffer -= delta
		if ground_buffer < 0:
			ground_buffer = 0
			character.current_jump = 0
	if ledge_buffer > 0 and !character.is_grounded():
		ledge_buffer -= delta
		if ledge_buffer < 0:
			ledge_buffer = 0	
	if jump_buffer > 0:
		jump_buffer -= delta
		if jump_buffer < 0:
			jump_buffer = 0
	if character.inputs[2][1]:
		jump_buffer = 0.075
	if character.inputs[3][1] and !(character.inputs[9][0] and character.is_grounded() and abs(character.velocity.x) <= 150):
		dive_buffer = 0.075
	if dive_buffer > 0:
		dive_buffer -= delta
		if dive_buffer < 0:
			dive_buffer = 0
	last_grounded = character.is_grounded()
	
func _stop(delta):
	character.squish_lerp = true
