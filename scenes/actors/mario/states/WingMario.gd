extends State

class_name WingMarioState

export var gravity_modifier = 4
export var max_speed = 260
export var accel = 1
export var turn_speed = 2.1

var rotation_down = 0
var old_gravity_scale = 0

func _ready():
	priority = 11
	blacklisted_states = []
	disable_movement = true
	disable_turning = true
	disable_friction = true
	disable_animation = true
	override_rotation = true

func _start_check(_delta):
	return false #character.state == character.get_state_node("DiveState")

func _start(_delta):
	old_gravity_scale = character.gravity_scale
	character.gravity_scale = 0
	character.velocity.y /= 5
	rotation_down = 90

func _update(_delta):
	if character.facing_direction == 1:
		character.sprite.animation = "idleRight"
	else:
		character.sprite.animation = "idleLeft"
	character.sprite.rotation_degrees = rotation_down
	#rotation_down = lerp(abs(rotation_down), 180, 0)
	rotation_down = clamp(abs(rotation_down), 0, 180)
	
	var rotation_normal = Vector2(cos(rotation_down), sin(rotation_down))
	
	character.velocity = Vector2((0.5 - abs(rotation_normal.x)) * 90, accel * 2)
	
	if character.inputs[character.input_names.left][character.input_params.pressed]:
		rotation_down -= turn_speed
	elif character.inputs[character.input_names.right][character.input_params.pressed]:
		rotation_down += turn_speed
	
	accel = rotation_down - 90

func _stop(_delta):
	character.gravity_scale = old_gravity_scale

func _stop_check(_delta):
	return character.is_grounded()

