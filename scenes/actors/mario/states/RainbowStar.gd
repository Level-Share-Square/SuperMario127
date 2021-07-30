extends State

class_name RainbowStarState

export var run_speed = 465
export var jump_power = 495
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

func _start(_delta):

	if abs(character.velocity.x) < 15:
		character.velocity.x = character.facing_direction * 15
	current_speed = abs(character.velocity.x)
	character.water_check.enabled = true

func _update(delta):
	if character.is_grounded():
		override_rotation = false
		if character.facing_direction == 1:
			character.sprite.animation = "starRunRight"
		else:
			character.sprite.animation = "starRunLeft"
		character.sprite.rotation_degrees = 0
	else:
		override_rotation = true
		if character.facing_direction == 1:
			character.sprite.animation = "tripleJumpRight"
		else:
			character.sprite.animation = "tripleJumpLeft"
		character.sprite.rotation_degrees += 24 * character.facing_direction
	character.sprite.speed_scale = (abs(character.velocity.x) / run_speed)
	
	if character.velocity.x == 0:
		character.facing_direction = -character.facing_direction
		character.velocity.x = current_speed * character.facing_direction
		character.position.x += character.facing_direction * 3
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
		current_speed = lerp(current_speed, run_speed, fps_util.PHYSICS_DELTA * 4.5)
		if footstep_interval <= 0 and character.sprite.speed_scale > 0:
			character.sound_player.play_footsteps()
			footstep_interval = clamp(0.8 - (character.sprite.speed_scale / 1.25), 0.1, 1)
		footstep_interval -= delta
	character.velocity.x = character.facing_direction * current_speed
	
	if (character.is_grounded() and had_jumped) or (character.powerup == null or character.powerup.id != "Rainbow"):
		had_jumped = false
	
	if jumping:
		if !character.inputs[2][0]:
			character.velocity.y *= fall_multiplier
			jumping = false
		if character.velocity.y >= 0:
			jumping = false
			
	if had_jumped and character.inputs[9][1]:
		had_jumped = false
	
	current_speed = clamp(current_speed, -run_speed * 2, run_speed * 2)
	
	if character.water_check.is_colliding() and !character.swimming:
		if !jumping:
			character.velocity.y = 10
		character.global_position.y = character.water_check.get_collision_point().y - 24

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

func _stop(_delta):
	character.water_check.enabled = false

func _stop_check(_delta):
	return (character.powerup == null or character.powerup.id != "Rainbow") and character.is_grounded()
