extends State

class_name WingMarioState

export var gravity_modifier = 4
export var max_speed = 560
export var momentum = 1
export var accel = 1
export var turn_speed = 2.1

var rotation_down = 0
var old_gravity_scale = 0

var current_speed = 0

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
	current_speed = 0
	character.velocity.y /= 5
	rotation_down = 90

func _update(delta):
	# Here's my latest attempt at coding this thing, as you can see i kind of failed terribly.
	# If you end up doing the code for this yourself, i'd recommend deleting most of this
	# as it's not very useful for future attempts and hasn't been cleaned up or commented

	if character.facing_direction == 1:
		character.sprite.animation = "idleRight"
	else:
		character.sprite.animation = "idleLeft"
	character.sprite.rotation_degrees = rotation_down
	#rotation_down = lerp(abs(rotation_down), 180, 0)
	rotation_down = clamp(abs(rotation_down), 0, 180)
	
	var rotation_normal = Vector2(cos(rotation_down), sin(rotation_down))
	
	character.velocity.y += momentum / 80
	character.velocity.x = (0.5 - abs(rotation_normal.x)) * 0
	
	if character.inputs[character.input_names.left][0]:
		rotation_down -= turn_speed
	elif character.inputs[character.input_names.right][0]:
		rotation_down += turn_speed
	
	momentum = (rotation_down - 160) * 3
	if momentum < 0:
		momentum *= 1

func _stop_check(_delta):
	return character.is_grounded()

