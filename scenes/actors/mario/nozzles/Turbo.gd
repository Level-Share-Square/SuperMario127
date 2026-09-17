extends Nozzle

class_name TurboNozzle

const LAND_SQUISH := Vector2(1.3, 0.7)
const SPEED_CAP: int = 700

onready var turbo_head = $"%TurboHead"

var cur_global_rotation: float = 0

export var head_position_left: Vector2
export var head_position_right: Vector2
export var head_luigi_offset: Vector2

export var boost_power := 1000
export var depletion := 100
export var fuel_depletion := 0.037
var last_charged = false

var attack_frames = 0
var accel = 25

func _init():
	blacklisted_states = ["ButtSlideState", "LavaBoostState", "WallSlideState", "GroundPoundStartState", "GroundPoundState", "GroundPoundEndState", "GetupState", "KnockbackState", "BonkedState", "SpinningState"]

func _activate_check(_delta):
	if character.state == character.get_state_node("SwimmingState"):
		if character.state.boost_time_left > 0:
			return false
	if character.state == character.get_state_node("BackflipState"):
		if character.state.disable_turning:
			return false
	return true
	
func is_state(state):
	return character.state == character.get_state_node(state)
	
func _activated_update(delta):
	character.turbo_particles.process_material.initial_velocity = 1000 - abs(character.velocity.x)
	var direction_vector: Vector2
	direction_vector.x = int(character.inputs[character.input_names.right][0]) - int(character.inputs[character.input_names.left][0])
	direction_vector.y = int(character.inputs[character.input_names.down][0]) - int(character.inputs[character.input_names.up][0])
	if character.is_walled():
		var direction = -1
		if character.is_walled_right():
			direction = 1
		character.damage_with_knockback(character.position + Vector2(direction * 8, 0), 0, "Hit", 0)
		character.bonk_particles.restart()
		character.sprite.scale = LAND_SQUISH
		character.squish_lerp = true
		character.bonk_particles.emitting = true
		if direction == 1:
			character.bonk_particles.process_material.direction = Vector3(-500, 0, 0)
			character.bonk_particles.position = Vector2(13, 7)
		else:
			character.bonk_particles.process_material.direction = Vector3(500, 0, 0)
			character.bonk_particles.position = Vector2(-13, 7)
	
	if character.fuel > 0 and !character.check_liquid(LiquidBase.LiquidType.Water):
		character.fuel -= fuel_depletion
		if character.fuel <= 0:
			character.fuel = 0
			
	if character.inputs[0][0] and !character.inputs[1][0]:
		character.facing_direction = -1
	elif character.inputs[1][0] and !character.inputs[0][0]:
		character.facing_direction = 1
	
	#IDK IF THIS DOES ANYTHING IMPORTANT
	character.water_check.enabled = true if !character.check_liquid(LiquidBase.LiquidType.Water) else false
	if character.water_check.is_colliding() and !character.check_liquid(LiquidBase.LiquidType.Water):
		if character.state == null:
			character.velocity.y = 10
			character.global_position.y = character.water_check.get_collision_point().y - 20
		character.breath = 100
		if character.get_input(2, true):
			character.global_position.y -= 15

	if is_instance_valid(character.state) and character.state.name == "SwimmingState":
		var dir: Vector2 = character.get_state_node("SwimmingState").last_move_vector
		var speed_limit = dir * SPEED_CAP
		character.velocity = lerp(character.velocity, speed_limit, 0.05)
		
	else:
		var normal = character.sprite.transform.x.normalized()
		var power = boost_power
		character.velocity.x += (accel * normal.x) * character.facing_direction
		character.velocity.y += (accel * 0.1 * normal.y) * character.facing_direction
		if character.velocity.x > boost_power and character.facing_direction == 1:
			character.velocity.x -= accel
		if character.velocity.x < -boost_power and character.facing_direction == -1:
			character.velocity.x += accel


func _update(delta):
	if is_instance_valid(character.state) and character.state.name == "SwimmingState" and character.state.boost_time_left <= 0:
		var dir: Vector2 = character.get_state_node("SwimmingState").last_move_vector
		turbo_head.visible = true
		turbo_head.position = head_position_left if character.sprite.flip_h else head_position_right
		if character.character == 1:
			turbo_head.position += head_luigi_offset * Vector2(-1 if character.sprite.flip_h else 1, 1)
		cur_global_rotation = lerp_angle(cur_global_rotation, dir.angle(), delta * 24)
		turbo_head.global_rotation = cur_global_rotation
		character.turbo_particles.emitting = false
		character.turbo_water_particles.emitting = activated and true
	else:
		turbo_head.visible = false
		character.turbo_particles.emitting = activated and true
		character.turbo_water_particles.emitting = false
	
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
		turbo_head.visible = false
		return
		
	if activated and !character.turbo_sound.playing:
		last_activated = false
	
	character.water_sprite.rotation_degrees = 90 * character.facing_direction
	if activated and !last_activated:
		character.emit_signal("fludd_activated")
		
		LastInputDevice.rumble(0.4, 0.0, 0.0)
		character.water_sprite.frame = 0
		character.turbo_sound.play()
		last_activated = true
	elif !activated and last_activated:
		character.emit_signal("fludd_deactivated")
		
		LastInputDevice.stop_rumble()
		character.turbo_particles.emitting = false
		character.turbo_water_particles.emitting = false
		character.water_sprite.frame = 0
		character.turbo_sound.stop()
		last_activated = false
		character.water_check.enabled = false
		turbo_head.hide()
	
	if !activated:
		character.using_turbo = false
		character.turbo_nerf = false
