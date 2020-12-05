extends Nozzle

class_name RocketNozzle

export var boost_power := 5000
export var depletion := 100
export var fuel_depletion := 5
var last_activated = false
var last_charged = false
var last_state = null

var accel = 825
var charge = 0
var rotation_interpolation_speed = 35
var deactivate_frames = 0
var cooldown_time = 2

func _init():
	blacklisted_states = ["GroundPoundStartState", "GroundPoundState", "GroundPoundEndState","KnockbackState", "BonkedState"]

func _activate_check(_delta):
	return !(character.state == character.get_state_node("BackflipState") and character.state.disable_turning == true) and character.get_state_node("SlideState").crouch_buffer == 0
	
func is_state(state):
	return character.state == character.get_state_node(state)
		
func _activated_update(delta):
	if last_activated and deactivate_frames > 0:
		return
	if charge < 0.75:
		if !character.fludd_charge_sound.is_playing():
			character.fludd_charge_sound.play()
		charge += delta
		character.fludd_sprite.modulate = Color(1, 1 - (charge * 1.4), 1 - (charge * 1.4))
		character.fludd_sprite.offset = Vector2(rand_range(-1, 1), rand_range(-1, 1)) * charge
		return
		
	character.fludd_sprite.offset = Vector2(0, 0)
	character.fludd_sprite.modulate = Color(1, 1, 1)
	character.fludd_charge_sound.stop()
	character.fludd_boost_sound.play()
	charge = 0
	character.stamina = 0
	character.get_state_node("JumpState").ledge_buffer = 0 # Disable coyote time, which allowed for a "double jump" that was weaker than the actual blast
	deactivate_frames = 30
		
	if !is_state("DiveState") and !is_state("SlideState"):
		if character.facing_direction == 1:
			character.sprite.animation = "jumpRight"
		else:
			character.sprite.animation = "jumpLeft"
		
	if (character.state == null or !character.state.override_rotation) and !character.rotating_jump:
		override_rotation = true
		var sprite = character.sprite
		var sprite_rotation = (character.velocity.x / character.move_speed) * 8
		sprite.rotation_degrees = lerp(sprite.rotation_degrees, sprite_rotation, delta * rotation_interpolation_speed)
	else:
		override_rotation = false
			
	var normal = character.sprite.transform.y.normalized()
	character.jump_animation = 0
	
	var power = -boost_power
	if abs(character.velocity.x) < abs(power * normal.x) * 3.5:
		#character.velocity.x = sqrt(abs(character.velocity.x)) * sign(character.velocity.x)
		character.velocity.x -= accel * normal.x
	
	if (character.velocity.y > power * normal.y and normal.y > 0) or (character.velocity.y < power * normal.y and normal.y < 0):
		character.velocity.y = sqrt(abs(character.velocity.y)) * sign(character.velocity.y)
		character.velocity.y -= accel * normal.y
	
	if character.fuel > 0:
		character.fuel -= fuel_depletion
		if character.fuel <= 0:
			character.fuel = 0
			
	if character.move_direction == 0 and !character.is_grounded():
		if (character.velocity.x > 0):
			character.velocity.x -= 1
		elif (character.velocity.x < 0):
			character.velocity.x += 1
	
func _update(_delta):
	if character.is_grounded():
		character.stamina = 100

	if !activated:
		override_rotation = false
	
	if !activated:
		character.fludd_sprite.modulate = Color(1, 1 - (charge * 1.4), 1 - (charge * 1.4))

	last_state = character.state

func _general_update(_delta):
	if activated and !last_activated and character.stamina == 0:
		character.rocket_particles.emitting = true
		character.fludd_sound.play(((100 - character.stamina) / 100) * 2.79)
		last_activated = true
	elif last_activated:
		if deactivate_frames > 0:
			deactivate_frames -= 1
		else:
			character.rocket_particles.emitting = false
			character.fludd_sound.stop()
			character.fludd_sprite.offset = Vector2(0, 0)
			last_activated = false
	
	if !activated:
		if last_charged:
			character.fludd_charge_sound.stop()
		
		charge -= _delta * 2
		character.fludd_sprite.modulate = Color(1, 1 - (charge * 1.4), 1 - (charge * 1.4))
		character.fludd_sprite.offset = Vector2(0, 0)
		
		if charge < 0:
			charge = 0
	last_charged = activated
