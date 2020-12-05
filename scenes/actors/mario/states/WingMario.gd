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
	return (character.rotating_jump or character.state == character.get_state_node("DiveState")) and character.velocity.y > 0 and (character.powerup != null and character.powerup.id == 3)

func _start(_delta):
	# Don't even question it, it just works
	rotation_down = clamp(90 + sqrt(0.0 if character.velocity.y < 0 else character.velocity.y), 90, 180)
	momentum = sqrt(character.velocity.length()) * 10

func _update(delta):
	# Things can - and probably should - be tweaked here
	
	# Capping rotation
	var clamp_max : float = lerp(rotation_down, 220 - momentum / 1.5, delta * 4)
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
	momentum = lerp(momentum, 0, delta / 2.2)
	
	# apply bruh momentum
	character.velocity.y = lerp(character.velocity.y, -rotation_normal.y * momentum, delta * 20)
	character.velocity.x = lerp(character.velocity.x, character.facing_direction * rotation_normal.x * momentum * 1.5, delta * 20)
	
	# Turning
	var final_turn_speed : float = turn_speed * delta * pow(momentum, 0.4)
	if character.inputs[character.input_names.left][0]:
		turn_multiplier -= turn_multiplier_accel * delta
	elif character.inputs[character.input_names.right][0]:
		turn_multiplier += turn_multiplier_accel * delta
	elif abs(turn_multiplier) > 0.01: # Some margin of error
		turn_multiplier -= turn_multiplier_accel * delta * sign(turn_multiplier)
	else:
		turn_multiplier = 0.0
	
	turn_multiplier = clamp(turn_multiplier, -1.0, 1.0)
	
	rotation_down += final_turn_speed * character.facing_direction * turn_multiplier
	
	# Turning around
	if (rotation_down > 180 or rotation_down < 0): # and character.inputs[character.input_names.spin][0]:
		character.facing_direction *= -1
	
	# Sprite animation and rotation
	character.sprite.animation = "flyRight" if character.facing_direction == 1 else "flyLeft"
	character.sprite.rotation = lerp_angle(character.sprite.rotation, deg2rad(rotation_down * character.facing_direction), delta * 12)
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

func _stop_check(_delta):
	return character.is_grounded() or (character.powerup == null or character.powerup.id != 3) or character.inputs[5][1]

