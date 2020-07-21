extends Nozzle

class_name RocketNozzle

export var boost_power := 5000
export var depletion := 100
export var fuel_depletion := 5
var last_activated = false
var last_charged = false
var last_state = null

var accel = 750
var charge = 0
var rotation_interpolation_speed = 35
var deactivate_frames = 0

func _init():
	blacklisted_states = ["ButtSlideState", "WallSlideState", "GroundPoundStartState", "GroundPoundState", "GroundPoundEndState", "GetupState", "KnockbackState", "BonkedState", "SpinningState"]

func _activate_check(_delta):
	return !(character.state == character.get_state_node("BackflipState") and character.state.disable_turning == true) and character.get_state_node("SlideState").crouch_buffer == 0
	
func is_state(state):
	return character.state == character.get_state_node(state)
	
func _activated_update(delta):
	if charge < 1.5:
		if !character.fludd_charge_sound.is_playing():
			character.fludd_charge_sound.play()
		charge += delta
		return
	
	charge = 0
	character.stamina = 0
	deactivate_frames = 5
	
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
	if abs(character.velocity.x) < abs(power * normal.x) * 8:
		character.velocity.x = sqrt(abs(character.velocity.x)) * sign(character.velocity.x)
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

	last_state = character.state

func _process(_delta):
	if character.nozzle == self:
		if character.water_sprite.flip_h:
			character.water_sprite.flip_h = false
		else:
			character.water_sprite.flip_h = true

func _general_update(_delta):
	if activated and !last_activated and character.stamina == 0:
		var normal = character.sprite.transform.y.normalized()
		var power = -boost_power * 4
		if abs(character.velocity.x) < abs(power * normal.x) * 8:
			character.velocity.x -= accel * normal.x

		character.water_sprite.animation = "out"
		character.water_sprite.frame = 0
		character.fludd_charge_sound.stop()
		character.fludd_sound.play(((100 - character.stamina) / 100) * 2.79)
		last_activated = true
	elif !activated and last_activated:
		if deactivate_frames > 0:
			deactivate_frames -= 1
		else:
			character.water_sprite.animation = "in"
			character.water_sprite.frame = 0
			character.fludd_sound.stop()
			last_activated = false
	
	if !activated:
		if last_charged:
			character.fludd_charge_sound.stop()
		charge -= _delta * 2
		if charge < 0:
			charge = 0
	last_charged = activated
