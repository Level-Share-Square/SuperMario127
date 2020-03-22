extends State

class_name SlideState

onready var dive_player = character.get_node("JumpSoundPlayer")

var stop = false
var getup_buffer = 0

func _ready():
	priority = 4
	disable_movement = true
	disable_animation = true

func _start(delta):
	if character.state != character.get_state_node("Jump"):
		var sprite = character.animated_sprite
		character.friction = 4
	
func _update(delta):
	var sprite = character.animated_sprite
	if (character.facing_direction == 1):
		sprite.animation = "diveRight"
	else:
		sprite.animation = "diveLeft"
	sprite.rotation_degrees = 90 * character.facing_direction
		
	if getup_buffer > 0:
		stop = true

func _stop(delta):
	var collision = character.get_node("collision")
	var dive_collision = character.get_node("dive_collision")
	var sprite = character.animated_sprite
	character.friction = character.real_friction
	if !character.is_grounded():
		character.set_state_by_name("DiveState", delta)
	elif getup_buffer > 0 or abs(character.velocity.x) < 5:
		character.set_state_by_name("GetupState", delta)
		if !character.test_move(character.transform, Vector2(0, -16)):
			character.position.y -= 16
		collision.disabled = false
		dive_collision.disabled = true
	else:
		sprite.rotation_degrees = 0
		collision.disabled = false
		dive_collision.disabled = true
	stop = false

func _stop_check(delta):
	return abs(character.velocity.x) < 5 or stop or !character.is_grounded()

func _general_update(delta):
	if character.is_action_just_pressed("jump"):
		getup_buffer = 0.075
	if getup_buffer > 0:
		getup_buffer -= delta
		if getup_buffer < 0:
			getup_buffer = 0
