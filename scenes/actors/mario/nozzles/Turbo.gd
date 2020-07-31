extends Nozzle

class_name TurboNozzle

export var boost_power := 5000
export var depletion := 100
export var fuel_depletion := 0.035
var last_activated = false
var last_charged = false
var last_state = null

var attack_frames = 0
var accel = 750
var charge = 0
var boosted = false

func _init():
	blacklisted_states = ["ButtSlideState", "WallSlideState", "GroundPoundStartState", "GroundPoundState", "GroundPoundEndState", "GetupState", "KnockbackState", "BonkedState", "SpinningState"]

func _activate_check(_delta):
	return !(character.state == character.get_state_node("BackflipState") and character.state.disable_turning == true) and character.get_state_node("SlideState").crouch_buffer == 0
	
func is_state(state):
	return character.state == character.get_state_node(state)
	
func _activated_update(delta):
	if charge < 2 and !character.inputs[0][0] and !character.inputs[1][0] and !boosted:
		if !character.fludd_charge_sound.is_playing():
			character.fludd_charge_sound.play()
		charge += delta
		character.using_turbo = true
		character.turbo_nerf = true
		if charge > 1:
			character.sprite.position += Vector2(sin(charge * 60), 0)
		return
	
	if charge > 1:
		charge = 1
	elif charge < 0.25:
		boosted = true # Didn't charge quite enough
		attack_frames = 0
	
	character.fludd_charge_sound.stop()
	
	var normal = character.sprite.transform.x.normalized()
	character.jump_animation = 0
	
	if !boosted:
		character.sprite.position = Vector2(0, 0)
		accel *= 1 + charge * 2
		attack_frames = charge * 60
	
	var dest_x = lerp(character.velocity.x, accel * normal.x * character.facing_direction, delta * (5 if boosted else 60))
	if abs(dest_x) > abs(character.velocity.x) or !boosted:
		character.velocity.x = dest_x
	var dest_y = lerp(character.velocity.y, accel * normal.y * 0.5 * character.facing_direction, delta * (5 if boosted else 60))
	if abs(dest_y) > abs(character.velocity.y) or !boosted:
		character.velocity.y = dest_y
	
	if !boosted:
		accel /= 1 + charge * 2
		boosted = true
	
	character.using_turbo = true
	character.turbo_nerf = attack_frames <= 0
	attack_frames -= 1
	
	if character.is_walled():
		character.damage_with_knockback(character.position + Vector2(character.facing_direction * 8, 0), 0, "Hit", 0)
	
	if character.fuel > 0:
		character.fuel -= fuel_depletion
		if character.fuel <= 0:
			character.fuel = 0
	
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

func _general_update(delta):
	if character.nozzle != self:
		return
	
	character.water_sprite.rotation_degrees = 90 * character.facing_direction
	if boosted and activated and !last_activated:
		character.water_sprite.animation = "out"
		character.water_sprite.frame = 0
		character.fludd_sound.play(((100 - character.stamina) / 100) * 2.79)
		last_activated = true
	elif !activated and last_activated:
		character.water_sprite.animation = "in"
		character.water_sprite.frame = 0
		character.fludd_sound.stop()
		charge = 0
		last_activated = false
	
	if !activated:
		if character.fludd_charge_sound.is_playing():
			character.fludd_charge_sound.stop()
		charge = 0
		boosted = false
		character.using_turbo = false
		character.turbo_nerf = false
