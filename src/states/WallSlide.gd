extends State

class_name WallSlideState

var wall_buffer = 0.0

func _startCheck(delta):
	return character.isWalled()

func _start(delta):
	if character.isWalledRight():
		character.direction_on_stick = 1
	else:
		character.direction_on_stick = -1
	wall_buffer = 0.075
	pass

func _update(delta):
	if !character.isWalled() || character.isGrounded():
		wall_buffer -= delta
		if wall_buffer <= 0:
			wall_buffer = 0
	else:
		var sprite = character.get_node("AnimatedSprite")
		if character.direction_on_stick == 1:
			sprite.animation = "wallSlideRight"
		else:
			sprite.animation = "wallSlideLeft"
		wall_buffer = 0.075
	pass

func _stop(delta):
	wall_buffer = 0
	pass

func _stopCheck(delta):
	return wall_buffer <= 0
