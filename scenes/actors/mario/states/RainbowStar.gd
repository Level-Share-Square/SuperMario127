extends State

class_name RainbowStarState

export var run_speed = 425
export var jump_power = 450
export var wall_jump_power = 350
export var fall_multiplier = 0.55

var current_speed = 0
var jumping = false

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
	character.sprite.speed_scale = 3.5
	
	character.velocity.x = character.facing_direction * current_speed
	if character.is_walled():
		character.velocity.x = -character.velocity.x
		character.position.x -= character.facing_direction * 3
		character.facing_direction = -character.facing_direction
		if !character.is_grounded():
			character.position.y -= 3
			character.velocity.y = -wall_jump_power
			jumping = false
			current_speed = run_speed * 1.3
	
	if character.inputs[2][1] and character.is_grounded():
		character.velocity.y = -jump_power
		character.position.y -= 3
		jumping = true
	
	if jumping:
		if !character.inputs[2][0]:
			character.velocity.y *= fall_multiplier
			jumping = false
		if character.velocity.y >= 0:
			jumping = false
	
	if character.facing_direction == 1:
		if character.inputs[1][0] and character.is_grounded():
			current_speed = lerp(current_speed, run_speed * 1.25, delta * 3)
		elif character.inputs[0][0] and character.is_grounded():
			current_speed = lerp(current_speed, run_speed * 0.75, delta * 3)
		else:
			current_speed = lerp(current_speed, run_speed, delta * 3)
	else:
		if character.inputs[2][0] and character.is_grounded():
			current_speed = lerp(current_speed, run_speed * 1.25, delta * 3)
		elif character.inputs[1][0] and character.is_grounded():
			current_speed = lerp(current_speed, run_speed * 0.75, delta * 3)
		else:
			current_speed = lerp(current_speed, run_speed, delta * 3)
