extends State

class_name WallJumpState

export var walljump_power = Vector2(350, 320)
export var minimum_power = 225
var actual_power

var press_buffer = 0.0
var wall_jump_timer = 0.0
var direction_on_wj = 1
var position_on_wj = Vector2(0, 0)
var character_in_range = false
var correcting_frames = 0

func _ready():
	actual_power = walljump_power
	priority = 2
	disable_turning = true
	blacklisted_states = ["DiveState", "BonkedState"]

func _start_check(_delta):
	var slide_check = ((character.is_walled_right() and (character.move_direction == 1 or character.is_wj_chained)) or (character.is_walled_left() and (character.move_direction == -1 or character.is_wj_chained))) and !character.is_grounded() and (!character.test_move(character.transform, Vector2(0, 16)) or character.velocity.y < 0 or character.is_wj_chained)
	return (character.state == character.get_state_node("WallSlideState") or slide_check) and press_buffer > 0

func _start(_delta):
	var sound_player = character.sound_player
	if character_in_range:
		actual_power.y /= 1.15
		if actual_power.y < minimum_power:
			actual_power.y = minimum_power
	else:
		actual_power = walljump_power
	press_buffer = 0
	position_on_wj = character.position
	if character.is_walled_right():
		character.direction_on_stick = 1
	elif character.is_walled_left():
		character.direction_on_stick = -1
	character.facing_direction = -character.direction_on_stick
	character.velocity.x = actual_power.x * character.facing_direction
	character.velocity.y = -actual_power.y
	character.position.x += 2 * -character.direction_on_stick
	character.position.y -= 2
	direction_on_wj = -character.direction_on_stick
	wall_jump_timer = 0.45
	sound_player.play_wall_jump_sound()
	character.jump_animation = 0
	character.is_wj_chained = true

func _update(_delta):
	var sprite = character.sprite
	if (direction_on_wj == 1):
		sprite.animation = "jumpRight"
	else:
		sprite.animation = "jumpLeft"
	pass

func _stop_check(_delta):
	return wall_jump_timer <= 0 or character.is_walled() or character.is_grounded()
	
func _general_update(delta):
	if character.position.x > position_on_wj.x - 3 and character.position.x < position_on_wj.x + 3:
		character_in_range = true
	else:
		character_in_range = false
	if character.is_grounded():
		character.is_wj_chained = false
		actual_power = walljump_power
	if character.inputs[2][1] and !character.is_grounded():
		press_buffer = 0.075
	if press_buffer > 0:
		press_buffer -= delta
		if press_buffer <= 0:
			press_buffer = 0
	if wall_jump_timer > 0:
		wall_jump_timer -= delta
		if wall_jump_timer <= 0:
			wall_jump_timer = 0
