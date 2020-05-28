extends State

class_name ButtSlideState

var stop_buffer = 0.0

export var acceleration = 20.5
export var move_speed = 376.0

var temp_accel = acceleration

func _ready():
	priority = 4
	disable_turning = true
	disable_movement = true
	disable_animation = true
	disable_snap = false
	blacklisted_states = ["SlideStopState", "GroundPoundEndState"]
	
func _start_check(_delta):
	var normal = character.ground_check.get_collision_normal()
	return character.inputs[9][1] and character.is_grounded() and normal.x != 0

func _start(delta):
	temp_accel = 0
	character.attacking = true
	if character.state != character.get_state_node("Jump"):
		character.friction = 4
	print("B")

func _update(delta):
	if temp_accel < acceleration:
		temp_accel += 0.25
	var sprite = character.animated_sprite
	if (character.facing_direction == 1):
		sprite.animation = "groundPoundEndRight"
	else:
		sprite.animation = "groundPoundEndLeft"
		
	if abs(character.velocity.x) > 50 and character.is_grounded():
		character.particles.emitting = true
	else:
		character.particles.emitting = false
		
	var normal = character.ground_check.get_collision_normal()
	var move_direction = stepify(normal.x, 1)
	if character.is_grounded():
		if ((character.velocity.x > 0 and move_direction == -1) or (character.velocity.x < 0 and move_direction == 1)):
			character.velocity.x += temp_accel * move_direction
		elif ((character.velocity.x < move_speed and move_direction == 1) or (character.velocity.x > -move_speed and move_direction == -1)):
			character.velocity.x += temp_accel * move_direction
		elif ((character.velocity.x > move_speed and move_direction == 1) or (character.velocity.x < -move_speed and move_direction == -1)):
			character.velocity.x -= 3.5 * move_direction

func _stop(delta):
	character.sound_player.set_skid_playing(false)
	character.particles.emitting = false
	character.friction = character.real_friction
	character.sound_player.set_skid_playing(false)
	character.particles.emitting = false
	character.attacking = false
	
func _stop_check(_delta):
	return false

func _general_update(delta):
	if character.state != self and character.state != character.get_state_node("WallSlideState"):
		character.sound_player.set_skid_playing(false)
		character.particles.emitting = false
