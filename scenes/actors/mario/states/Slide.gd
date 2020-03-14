extends State

class_name SlideState

onready var sprite = character.animated_sprite
onready var dive_player = character.get_node("JumpSoundPlayer")

export var get_up_power = 320

var stop_counter = 0.0

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
	
	if stop_counter > 0:
		stop_counter += delta
		sprite.rotation_degrees = 0
		if (character.facing_direction == 1):
			sprite.animation = "jumpRight"
		else:
			sprite.animation = "jumpLeft"
		
	if Input.is_action_pressed("jump") and stop_counter <= 0:
		character.velocity.y = -get_up_power
		character.position.y -= 1
		character.friction = character.real_friction
		sprite.rotation_degrees = 0
		stop_counter += delta

func _stop(delta):
	var sprite = character.animated_sprite
	character.friction = character.real_friction
	sprite.rotation_degrees = 0
	stop_counter = 0

func _stopCheck(delta):
	return abs(character.velocity.x) < 5 or stop_counter > 0.25
