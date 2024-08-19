extends State

class_name WingMarioState

export var gravity_modifier := 4.0
export var max_speed := 560.0
export var momentum := 1.0
export var accel := 1.0
export var turn_speed := 20

var accel_plus := 0.5
var rotation_down = 0
var old_gravity_scale = 0
var turn_multiplier := 0.0
var turn_multiplier_accel := 0.125 * 120 # 120 fps

var up_down_controls = false # for the legacy wing cap control option

func _ready():
	priority = 4
	blacklisted_states = []
	disable_movement = true
	disable_turning = true
	disable_friction = true
	disable_animation = true
	override_rotation = true
	use_dive_collision = true

func _start_check(_delta):
	return (character.rotating_jump or character.state == character.get_state_node("DiveState")) and character.velocity.y > 0 and (character.powerup != null and character.powerup.id == "Wing")

func _start(_delta):
	# Don't even question it, it just works
	rotation_down = clamp(90 + sqrt(0.0 if character.velocity.y < 0 else character.velocity.y), 90, 180)
	momentum = sqrt(character.velocity.length()) * 10
	character.camera.set_zoom_tween(Vector2(1.5, 1.5), 1.2)

func _update(delta):
	# Things can - and probably should - be tweaked here
	
	# Set control mode
	up_down_controls = LocalSettings.load_setting(
		"Controls (Player " + str(character.player_id + 1) + ")", 
		"63_wing_cap",
		false
	)
	
	# Capping rotation
	var clamp_max : float = lerp(rotation_down, 220 - momentum / 1.5, fps_util.PHYSICS_DELTA * 4)
	clamp_max = clamp(clamp_max, 0, 180)
	rotation_down = clamp(abs(rotation_down), clamp_max, 180)
	var rotation_normal = Vector2(sin(deg2rad(rotation_down)), cos(deg2rad(rotation_down)))
	
	# acceleration
	if rotation_normal.y < 0:
		momentum += (accel_plus + rotation_normal.y * rotation_normal.y) * 410 * delta / pow(max(1.0, momentum), 0.01)
	else:
		momentum -= accel_plus * (rotation_normal.y * rotation_normal.y * 410 * delta / pow(max(1.0, momentum), 0.01))
	if momentum < 0: momentum = 0
	
	# fludd acceleration
	#if character.nozzle != null:
	#	if character.fludd_sound.is_playing(): # Using fludd
	#		momentum += character.nozzle.accel / 8
	
	# drag
	momentum = lerp(momentum, 0, fps_util.PHYSICS_DELTA / 2.2)
	
	# apply bruh momentum
	character.velocity.y = lerp(character.velocity.y, -rotation_normal.y * momentum, fps_util.PHYSICS_DELTA * 20)
	character.velocity.x = lerp(character.velocity.x, character.facing_direction * rotation_normal.x * momentum * 1.5, fps_util.PHYSICS_DELTA * 20)
	
	# Calculating inputs
	var subtract_input = false
	var add_input = false
	if up_down_controls:
		# Basically, this automatically sets the inputs to work with the current code
		# This is just for 127gd, this should be implemented cleaner in 127cs ideally
		if character.inputs[character.input_names.up][0]:
			if character.facing_direction == 1:
				subtract_input = true
			else:
				add_input = true
		elif character.inputs[character.input_names.down][0]:
			if character.facing_direction == -1:
				subtract_input = true
			else:
				add_input = true
	else:
		subtract_input = character.inputs[character.input_names.left][0]
		add_input = character.inputs[character.input_names.right][0]
	
	# Turning
	var final_turn_speed : float = turn_speed * delta * pow(momentum, 0.4)
	if subtract_input:
		turn_multiplier -= turn_multiplier_accel * delta
	elif add_input:
		turn_multiplier += turn_multiplier_accel * delta
	elif abs(turn_multiplier) > 0.01: # Some margin of error
		turn_multiplier -= turn_multiplier_accel * delta * sign(turn_multiplier)
	else:
		turn_multiplier = 0.0
	
	turn_multiplier = clamp(turn_multiplier, -1.0, 1.0)
	
	rotation_down += final_turn_speed * character.facing_direction * turn_multiplier
	
	# Turning around
	if turn_conditions_met():
		character.facing_direction *= -1
	
	# Sprite animation and rotation
	character.sprite.animation = "flyRight" if character.facing_direction == 1 else "flyLeft"
	character.sprite.rotation = lerp_angle(character.sprite.rotation, deg2rad(rotation_down * character.facing_direction), fps_util.PHYSICS_DELTA * 12)
	if rotation_down > 110:
		character.sprite.frame = 0
	elif rotation_down < 50:
		character.sprite.frame = 2
	else:
		character.sprite.frame = 1
	
	# Hit wall
	if (character.facing_direction == 1 and character.is_walled_right())\
	or (character.facing_direction == -1 and character.is_walled_left())\
	or (character.is_ceiling()):
		character.damage_with_knockback(character.position + Vector2(character.facing_direction * 8, 0), 0, "Hit", 0)

func turn_conditions_met():
	return (rotation_down > 180 or rotation_down < 0) and (!up_down_controls or 
		(up_down_controls and (
			character.facing_direction == 1 and character.inputs[character.input_names.left][0]
			or character.facing_direction == -1 and character.inputs[character.input_names.right][0]
			)
		)
	)

func _stop(delta):
	if character.inputs[5][0]:
		character.set_state_by_name("GroundPoundStartState", delta)
		yield(get_tree(), "idle_frame")
		character.get_state_node("GroundPoundStartState").can_dive = false
	else:
		if character.is_grounded():
			character.set_state_by_name("SlideState", delta)
		else:
			character.set_state_by_name("DiveState", delta)
	character.camera.zoom_tween.remove_all()
	character.camera.set_zoom_tween(Vector2(1, 1), 0.5)
func _stop_check(_delta):
	return character.is_grounded() or (character.powerup == null or character.powerup.id != "Wing") or character.inputs[5][1]

