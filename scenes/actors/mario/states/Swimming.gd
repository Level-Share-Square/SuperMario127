extends State

class_name SwimmingState

var base_swim_speed = 285
var boost_speed = 450

var swim_speed = 255
var char_rotation = 90

var boost_time_left = 0.0
var boost_buffer = 0.0

var boost_disable_time = 0.0

var fuel_increment = 0.05

var max_enter_fall_speed = 160
var ground_pound_enter_speed = 350
var old_gravity_scale = 1

func _ready():
	priority = 6
	blacklisted_states = []
	disable_movement = true
	disable_turning = true
	disable_friction = true
	disable_animation = true
	override_rotation = true
	use_dive_collision = true

func _start_check(_delta):
	return character.water_detector.get_overlapping_areas().size() > 0 and !(character.powerup != null and character.powerup.id == 0)

func _start(_delta):
	character.sound_player.play_splash_sound()
	character.jump_animation = 0
	
	old_gravity_scale = character.gravity_scale
	character.velocity.y = clamp(character.velocity.y, -max_enter_fall_speed, max_enter_fall_speed)
	if character.last_state == character.get_state_node("GroundPoundState"):
		character.velocity.y = ground_pound_enter_speed
	
	character.swimming = true
	character.gravity_scale = 0
	char_rotation = 90 * character.facing_direction
	swim_speed = base_swim_speed
	boost_disable_time = 0.14

func _update(delta):
	var move_vector = Vector2()
	var sprite = character.sprite
	
	character.fuel = clamp(character.fuel + fuel_increment, 0, 100)
	character.stamina = 100
	
	if character.inputs[character.input_names.left][0]:
		move_vector.x -= 1
	if character.inputs[character.input_names.right][0]:
		move_vector.x += 1

	if character.inputs[character.input_names.up][0]:
		move_vector.y -= 1
	if character.inputs[character.input_names.down][0]:
		move_vector.y += 1
	
	if character.inputs[character.input_names.spin][1]:
		boost_buffer = 0.15
	
	if boost_buffer > 0 and boost_time_left <= 0.15 and boost_disable_time <= 0:
		character.velocity = Vector2.RIGHT.rotated(sprite.rotation - (PI/2)) * boost_speed
		swim_speed = boost_speed
		boost_buffer = 0
		boost_time_left = 0.75
		character.spin_area_shape.disabled = false
		character.sound_player.set_swim_playing(false)
		character.sound_player.play_spin_water_sound()
	
	if boost_time_left > 0:
		boost_time_left -= delta
		sprite.speed_scale = (boost_time_left / 0.375)
		if boost_time_left <= 0:
			boost_time_left = 0
			sprite.speed_scale = 0
			character.spin_area_shape.disabled = true
			character.sound_player.set_swim_playing(true)
			swim_speed = base_swim_speed

	if boost_buffer > 0:
		boost_buffer -= delta
		if boost_buffer <= 0:
			boost_buffer = 0

	if boost_disable_time > 0:
		boost_disable_time -= delta
		if boost_disable_time <= 0:
			boost_disable_time = 0
			character.sound_player.set_swim_playing(true)
			
	var lerp_speed = 480
	if boost_time_left > 0:
		lerp_speed = 1440
		swim_speed = base_swim_speed + ((boost_speed - base_swim_speed) * (boost_time_left / 0.375))

	if abs(move_vector.x) + abs(move_vector.y) != 0:
		char_rotation = Vector2().angle_to_point(move_vector) - (PI/2)
		character.velocity = character.velocity.move_toward(Vector2.RIGHT.rotated(sprite.rotation - (PI/2)) * swim_speed, delta * lerp_speed)
	else:
		character.velocity = character.velocity.move_toward(Vector2(), delta * (240 if (abs(character.velocity.x) <= base_swim_speed and abs(character.velocity.y) <= base_swim_speed) else 480))

	sprite.rotation = fmod(lerp_angle(sprite.rotation, char_rotation, delta * (7 if boost_time_left == 0 else 2)), 360)
	if abs(sprite.rotation) > PI:
		sprite.rotation = -sprite.rotation

	character.facing_direction = sign(sprite.rotation)
	sprite.animation = ("diveRight" if character.facing_direction == 1 else "diveLeft") if boost_time_left <= 0 else "spinning"

func _stop(delta):
	if boost_time_left == 0 and (abs(character.velocity.x) <= base_swim_speed and abs(character.velocity.y) <= base_swim_speed):
		character.velocity.x *= 1.5
		character.velocity.y *= 1.75

	boost_time_left = 0
	character.sprite.rotation = 0
	character.gravity_scale = 1
	character.swimming = false
	character.sound_player.play_splash_sound()
	character.sound_player.set_swim_playing(false)
	character.get_state_node("SpinningState").spin_timer = 0
	character.get_state_node("SpinningState").spin_disable_time = 0.25
	character.set_state_by_name("BounceState", delta)

func _stop_check(_delta):
	return character.water_detector.get_overlapping_areas().size() <= 0

