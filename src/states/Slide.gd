extends State

class_name SlideState

onready var sprite = character.get_node("AnimatedSprite")
onready var dive_player = character.get_node("JumpSoundPlayer")

export var get_up_power = 320

var stop_counter = 0.0

func _start(delta):
	var sprite = character.get_node("AnimatedSprite")
	character.friction = 2.25
	
func _update(delta):
	var sprite = character.get_node("AnimatedSprite")
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
		character.friction = 7.5
		sprite.rotation_degrees = 0
		stop_counter += delta

func _stop(delta):
	var sprite = character.get_node("AnimatedSprite")
	character.friction = 7.5
	sprite.rotation_degrees = 0
	stop_counter = 0

func _stopCheck(delta):
	return abs(character.velocity.x) < 5 or stop_counter > 0.35
