extends State

class_name JumpState

export var jump_power: float = 350
var jumpBuffer = 0
var jump_playing = false

func _startCheck(delta):
	return character.is_grounded() and jumpBuffer > 0 and character.state != character.get_state_instance("Slide")

func _start(delta):
	var jump_player = character.get_node("JumpSoundPlayer")
	character.velocity.y = -jump_power
	character.position.y -= 3
	jumpBuffer = 0
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

func _stopCheck(delta):
	return character.is_grounded()

func _generalUpdate(delta):
	if jumpBuffer > 0:
		jumpBuffer -= delta
		if jumpBuffer < 0:
			jumpBuffer = 0
	if Input.is_action_just_pressed("jump"):
		jumpBuffer = 0.075
