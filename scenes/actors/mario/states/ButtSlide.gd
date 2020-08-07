extends State

class_name ButtSlideState

var stop_buffer = 0.0

export var acceleration = 20.5
export var move_speed = 376.0

var temp_speed = move_speed

func _ready():
	priority = 4
	attack_tier = 1
	disable_turning = true
	disable_movement = true
	disable_animation = true
	disable_snap = false
	disable_friction = true
	blacklisted_states = ["SlideStopState", "GroundPoundEndState"]
	
func _start_check(_delta):
	var normal = character.ground_check.get_collision_normal()
	return (character.nozzle == null or !character.nozzle.activated) and character.inputs[9][1] and character.is_grounded() and abs(normal.x) > 0.2

var starting_slide_sign = 1
func _start(_delta):
	temp_speed = move_speed
	character.sound_player.set_skid_playing(true)
	stop_buffer = 0.5
	starting_slide_sign = sign(character.velocity.x)

func _update(delta):
	var sprite = character.sprite
	if (character.facing_direction == 1):
		sprite.animation = "groundPoundEndRight"
	else:
		sprite.animation = "groundPoundEndLeft"
		
	if abs(character.velocity.x) > 50 and character.is_grounded():
		character.slide_particles.emitting = true
	else:
		character.slide_particles.emitting = false
		
	var normal = character.ground_check.get_collision_normal()
	var move_direction = 0
	if abs(normal.x) > 0.2:
		if normal.x > 0:
			move_direction = 1
		else:
			move_direction = -1
	
	if character.left_check.is_colliding() and character.right_check.is_colliding():
		character.velocity.y = 550
	if character.is_grounded() and move_direction != 0:
		temp_speed += 2
		stop_buffer = 0.5
		character.velocity.x = lerp(character.velocity.x, temp_speed * move_direction, delta * 2)
	else:
		stop_buffer -= delta
		temp_speed = clamp(temp_speed - 2, move_speed, move_speed * 10)
		character.velocity.x = lerp(character.velocity.x, 0, delta * 2)
		
	if abs(character.velocity.x) < 20 and abs(normal.x) <= 0.2:
		stop_buffer = 0
		character.set_state_by_name("BounceState", delta)
		character.position.y -= 1
		character.velocity.y = -150
		
	if character.inputs[2][0]:
		character.set_state_by_name("JumpState", 0)
	
	# Prevent infinite slides between 2 slopes
	if sign(character.velocity.x) != starting_slide_sign:
		stop_buffer = 0
		character.set_state_by_name("BounceState", delta)
		character.position.y -= 1
		character.velocity.y = -150

func _stop(_delta):
	character.sound_player.set_skid_playing(false)
	character.slide_particles.emitting = false
	
func _stop_check(_delta):
	return stop_buffer == 0
