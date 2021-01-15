extends Nozzle

class_name HoverNozzle

export var boost_power := 170
export var depletion := 1.1
export var fuel_depletion := 0.035
var last_activated = false
var last_state = null

var accel = 30
var rotation_interpolation_speed = 35
var preservation_factor = 0

func _init():
	blacklisted_states = ["WingMarioState", "LavaBoostState", "RainbowStarState", "ButtSlideState", "WallSlideState", "GroundPoundStartState", "GroundPoundState", "GroundPoundEndState", "GetupState", "KnockbackState", "BonkedState", "SpinningState"]

func _activate_check(_delta):
	return !(character.state == character.get_state_node("SwimmingState") and character.state.boost_time_left > 0) and !(character.state == character.get_state_node("BackflipState") and character.state.disable_turning == true) and (character.get_state_node("SlideState").crouch_buffer == 0 or character.swimming)
	
func is_state(state):
	return character.state == character.get_state_node(state)
	
func _activated_update(delta):
	if !is_state("DiveState") and !is_state("SlideState") and !character.swimming:
		if character.facing_direction == 1:
			character.sprite.animation = "jumpRight"
		else:
			character.sprite.animation = "jumpLeft"

	if (character.state == null or !character.state.override_rotation) and !character.rotating_jump:
		override_rotation = true
		var sprite = character.sprite
		var sprite_rotation = (character.velocity.x / character.move_speed) * 6
		sprite.rotation_degrees = lerp(sprite.rotation_degrees, sprite_rotation, fps_util.PHYSICS_DELTA * rotation_interpolation_speed)
	else:
		override_rotation = false
			
	var normal = character.sprite.transform.y.normalized()
	character.jump_animation = 0
	
	var power = -boost_power * clamp(character.stamina / 100, 0.5, 1)
	
	if character.swimming:
		power *= 2
	
	if abs(character.velocity.x) < abs(power * normal.x) * (6 if !character.swimming else 1):
		character.velocity.x -= accel * (0.5 if character.swimming else 0.75) * normal.x
		
	if (character.velocity.y > power * normal.y and normal.y > 0) or (character.velocity.y < power * normal.y and normal.y < 0):
		character.velocity.y -= accel * (1 if !character.swimming else 0.75) * normal.y

	if !character.swimming:
		character.stamina -= depletion
	
	character.velocity.y += preservation_factor * (character.stamina / 100)
	
	if character.fuel > 0 and !character.swimming:
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

	last_state = character.state

func _process(_delta):
	if character.nozzle == self:
		if character.water_sprite.flip_h:
			character.water_sprite.flip_h = false
		else:
			character.water_sprite.flip_h = true

func _general_update(_delta):
	if activated and !last_activated:
		var normal = character.sprite.transform.y.normalized()
		var power = -boost_power * 4
		if abs(character.velocity.x) < abs(power * normal.x) * 8:
			character.velocity.x -= accel * normal.x

		character.water_particles.emitting = true
		character.water_particles_2.emitting = true
		#character.water_sprite.animation = "out"
		character.water_sprite.frame = 0
		character.fludd_sound.play(((100 - character.stamina) / 100) * 2.79)
		
		if character.velocity.y < 0 and character.stamina == 100:
			preservation_factor = character.velocity.y / 96
		else:
			preservation_factor = 0
	elif !activated and last_activated:
		character.water_particles.emitting = false
		character.water_particles_2.emitting = false
		#character.water_sprite.animation = "in"
		character.water_sprite.frame = 0
		character.fludd_sound.stop()
	elif !activated and !last_activated and character.fludd_sound.playing:
		character.fludd_sound.stop() #somehow there's a glitch where the sound never gets stopped, seems to be that activated gets set to false before last activated can be set to true, so it's sub-frame perfect if that's the case, this is kinda just a bandaid fix

	last_activated = activated
