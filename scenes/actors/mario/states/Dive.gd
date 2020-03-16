extends State

class_name DiveState

export var dive_power: Vector2 = Vector2(1350, 75)
export var bonk_power: float = 150
export var maxVelocityX: float = 700
var last_above_rot_limit = false
var dive_buffer = 0

func _ready():
	priority = 3
	disable_turning = true
	blacklisted_states = ["SlideState", "GetupState"]

func _start_check(delta):
	return dive_buffer > 0 and !character.test_move(character.transform, Vector2(0, 8)) and !character.is_walled()

func _start(delta):
	var dive_player = character.get_node("dive_sounds")
	if dive_buffer > 0:
		character.velocity.x = character.velocity.x - (character.velocity.x - (dive_power.x * character.facing_direction)) / 5
		character.velocity.y += dive_power.y
		dive_player.play()
	character.position.y -= 5
	character.rotating = true
	if abs(character.velocity.x) > maxVelocityX:
		character.velocity.x = maxVelocityX * character.facing_direction
	character.jump_animation = 0
	character.current_jump = 0

func _update(delta):
	var sprite = character.animated_sprite
	if (!character.is_grounded()):
		character.friction = character.real_friction
	if (character.facing_direction == 1):
		sprite.animation = "diveRight"
	else:
		sprite.animation = "diveLeft"
	var new_angle = ((character.velocity.y / 15) * character.facing_direction) + (90 * character.facing_direction)
	if (abs(new_angle) < 185):
		sprite.rotation_degrees = new_angle
		last_above_rot_limit = false
	else:
		if (!last_above_rot_limit):
			sprite.rotation_degrees = 185
		sprite.rotation_degrees += 0.35
		last_above_rot_limit = true
		
func _stop(delta):
	var sprite = character.animated_sprite
	sprite.rotation_degrees = 0
	if character.is_grounded():
		character.set_state_by_name("SlideState", delta)
	if character.is_walled():
		character.velocity.x = bonk_power * -character.facing_direction 
		character.position.x -= 2 * character.facing_direction
		character.set_state_by_name("BonkedState", delta)

func _stop_check(delta):
	return character.is_grounded() or (character.is_walled_right() && character.facing_direction == 1) or (character.is_walled_left() && character.facing_direction == -1)

func _general_update(delta):
	if Input.is_action_just_pressed("dive"):
		dive_buffer = 0.075
	if dive_buffer > 0:
		dive_buffer -= delta
		if dive_buffer < 0:
			dive_buffer = 0
