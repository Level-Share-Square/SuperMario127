extends State

class_name JumpState

export var jump_power: float = 350
var jump_buffer = 0
var jump_playing = false

func _start_check(delta):
	return character.is_grounded() and jump_buffer > 0 and character.state != character.get_state_instance("Slide")

func _start(delta):
	var jump_player = character.get_node("JumpSoundPlayer")
	character.velocity.y = -jump_power
	character.position.y -= 3
	jump_buffer = 0
	jump_playing = true
	jump_player.play()

func _update(delta):
	var sprite = character.get_node("AnimatedSprite")
	if jump_playing && character.velocity.y < 0 && !character.is_grounded():
		if character.facing_direction == 1:
			sprite.animation = "jumpRight"
		else:
			sprite.animation = "jumpLeft"
	else:
		jump_playing = false
		
func _stop(delta):
	pass

func _stop_check(delta):
	return character.is_grounded()

func _general_update(delta):
	if jump_buffer > 0:
		jump_buffer -= delta
		if jump_buffer < 0:
			jump_buffer = 0
	if Input.is_action_just_pressed("jump"):
		jump_buffer = 0.075
