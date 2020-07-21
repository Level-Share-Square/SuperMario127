extends State

class_name RainbowStarState

export var run_speed = 425
export var jump_power = 450
export var wall_jump_power = 350
export var fall_multiplier = 0.55

var current_speed = 0
var jumping = false
var had_jumped = false

var jump_buffer = 0.0
var ledge_buffer = 0.0
var footstep_interval = 0.0

func _ready():
	priority = 11
	blacklisted_states = []
	disable_movement = true
	disable_turning = true
	disable_friction = true
	disable_animation = true
	override_rotation = true

func _start_check(_delta):
	return false

func _start(delta):
	current_speed = run_speed

func _update(delta):
	if character.is_grounded():
		override_rotation = false
		if character.facing_direction == 1:
			character.sprite.animation = "movingRight"
		else:
			character.sprite.animation = "movingLeft"
		character.sprite.rotation_degrees = 0
	else:
		override_rotation = true
		if character.facing_direction == 1:
			character.sprite.animation = "tripleJumpRight"
		else:
			character.sprite.animation = "tripleJumpLeft"
		character.sprite.rotation_degrees += 12 * character.facing_direction
	character.sprite.speed_scale = (abs(character.velocity.x) / run_speed) * 3.5
	
	if character.velocity.x:
		pass
	
	character.velocity.x = character.facing_direction * current_speed
	if character.is_walled() or (character.position.x <= 0 or character.position.x >= character.level_size.x * 32):
		character.velocity.x = -character.velocity.x
		character.position.x -= character.facing_direction * 3
		character.facing_direction = -character.facing_direction
		if !character.is_grounded() and had_jumped:
			character.sound_player.play_wall_jump_sound_voiceless()
			character.position.y -= 3
			character.velocity.y = -wall_jump_power
			jumping = false
			current_speed = run_speed * 1.3
	
	if jump_buffer > 0 and ledge_buffer > 0:
		character.sound_player.play_dive_sound()
		jump_buffer = 0
		character.velocity.y = -jump_power
		character.position.y -= 3
		jumping = true
		had_jumped = true
		
	if character.is_grounded():
		current_speed = lerp(current_speed, run_speed, delta)
		if footstep_interval <= 0 and character.sprite.speed_scale > 0:
			character.sound_player.play_footsteps()
			footstep_interval = clamp(0.8 - (character.sprite.speed_scale / 2.5), 0.1, 1)
		footstep_interval -= delta
	
	if (character.is_grounded() and had_jumped) or (character.powerup == null or character.powerup.id != 1):
		had_jumped = false
	
	if jumping:
		if !character.inputs[2][0]:
			character.velocity.y *= fall_multiplier
			jumping = false
		if character.velocity.y >= 0:
			jumping = false
			
	if had_jumped and character.inputs[5][1]:
		had_jumped = false

func _general_update(delta):
	if jump_buffer > 0:
		jump_buffer -= delta
		if jump_buffer < 0:
			jump_buffer = 0
	if character.inputs[2][1]:
		jump_buffer = 0.075
	if character.is_grounded():
		ledge_buffer = 0.125

	if ledge_buffer > 0 and !character.is_grounded():
		ledge_buffer -= delta
		if ledge_buffer < 0:
			ledge_buffer = 0

func _stop_check(delta):
	return (character.powerup == null or character.powerup.id != 1) and character.is_grounded()
