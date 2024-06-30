extends Nozzle

class_name TurboNozzle

export var boost_power := 1000
export var depletion := 100
export var fuel_depletion := 0.037
var last_activated = false
var last_charged = false
var last_state = null

var attack_frames = 0
var accel = 25

func _init():
	blacklisted_states = ["ButtSlideState", "LavaBoostState", "WallSlideState", "GroundPoundStartState", "GroundPoundState", "GroundPoundEndState", "GetupState", "KnockbackState", "BonkedState", "SpinningState"]

func _activate_check(_delta):
	return !(character.state == character.get_state_node("SwimmingState") and character.state.boost_time_left > 0) and !(character.state == character.get_state_node("BackflipState") and character.state.disable_turning == true) and character.get_state_node("SlideState").crouch_buffer == 0
	
func is_state(state):
	return character.state == character.get_state_node(state)
	
func _activated_update(delta):	
	character.turbo_particles.process_material.initial_velocity = 1000 - abs(character.velocity.x)
	
	var normal = character.sprite.transform.x.normalized()
	var power = boost_power
	character.velocity.x += (accel * normal.x) * character.facing_direction
	character.velocity.y += (accel * 0.1 * normal.y) * character.facing_direction
	
	if character.velocity.x > boost_power and character.facing_direction == 1:
		character.velocity.x -= accel
	if character.velocity.x < -boost_power and character.facing_direction == -1:
		character.velocity.x += accel

	if character.is_walled():
		var direction = -1
		if character.is_walled_right():
			direction = 1
		character.damage_with_knockback(character.position + Vector2(direction * 8, 0), 0, "Hit", 0)
	
	if character.fuel > 0 and !character.water_detector.get_overlapping_areas().size() > 0:
		character.fuel -= fuel_depletion
		if character.fuel <= 0:
			character.fuel = 0
			
	if character.inputs[0][0] and !character.inputs[1][0]:
		character.facing_direction = -1
	elif character.inputs[1][0] and !character.inputs[0][0]:
		character.facing_direction = 1
	
	character.water_check.enabled = true if !character.water_detector.get_overlapping_areas().size() > 0 else false
	if character.water_check.is_colliding() and !character.water_detector.get_overlapping_areas().size() > 0:
		if character.state == null:
			character.velocity.y = 10
		character.global_position.y = character.water_check.get_collision_point().y - 20
		character.breath = 100
		if character.get_input(2, true):
			character.global_position.y -= 15

func _update(_delta):
	if character.is_grounded():
		character.stamina = 100

	if !activated:
		override_rotation = false

	last_state = character.state

func _process(_delta):
	if character.nozzle == self:
		if character.water_sprite.flip_h:
			character.water_sprite.flip_h = false
		else:
			character.water_sprite.flip_h = true

func _general_update(_delta):
	if character.nozzle != self:
		return
	
	character.water_sprite.rotation_degrees = 90 * character.facing_direction
	if activated and !last_activated:
		character.turbo_particles.emitting = true
		character.water_sprite.frame = 0
		character.turbo_sound.play()
		last_activated = true
	elif !activated and last_activated:
		character.turbo_particles.emitting = false
		character.water_sprite.frame = 0
		character.turbo_sound.stop()
		last_activated = false
		character.water_check.enabled = false
	
	if !activated:
		character.using_turbo = false
		character.turbo_nerf = false
