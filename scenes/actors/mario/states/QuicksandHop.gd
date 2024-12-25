class_name QuicksandHopState
extends State

export var jump_strength : float = 100.0
export var jump_length : int = 5

var length_remaining : int = jump_length
var working_jump_strength : float = jump_strength

var jump_buffer : float = 0
var dive_buffer : float = 0

func _ready():
	priority = 6
	blacklisted_states = ["BounceState", "DiveState", "SlideState", "GetupState", "BackflipState"]

func _start_check(_delta):
	for area in character.liquid_detector.get_overlapping_areas():
		var liquid : LiquidBase = area.get_parent()
		if liquid.liquid_type == liquid.LiquidType.Quicksand:
			return (jump_buffer > 0 or (dive_buffer > 0 and abs(character.velocity.x) > 50 and !character.test_move(character.transform, Vector2(8 * character.facing_direction, 0))))

func _start(delta):
	length_remaining = jump_length
	
	character.quicksand_particles.emitting = true
	character.quicksand_particles2.emitting = true
	character.sound_player.play_jump_sound()
	character.velocity.y = -working_jump_strength
	character.position.y -= 3
	character.jump_animation = 0
	character.current_jump = 1

func _update(delta):
	if character.facing_direction == 1:
		if character.jump_animation == 0:
			character.sprite.animation = "jumpRight"
	elif character.facing_direction == -1:
		if character.jump_animation == 0:
			character.sprite.animation = "jumpLeft"

func _stop_check(_delta):
	length_remaining -= 1
	var check = length_remaining <= 0 or character.velocity.y > 0
	if check:
		character.quicksand_particles.emitting = false
		character.quicksand_particles2.emitting = false
	return check

func _general_update(delta):
	if jump_buffer > 0:
		jump_buffer -= delta
		if jump_buffer < 0:
			jump_buffer = 0
	if character.inputs[2][1]:
		jump_buffer = 0.075
	if character.inputs[3][1] and !(character.inputs[9][0] and abs(character.velocity.x) <= 150):
		dive_buffer = 0.075
	if dive_buffer > 0:
		dive_buffer -= delta
		if dive_buffer < 0:
			dive_buffer = 0
