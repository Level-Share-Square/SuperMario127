extends State

class_name WallSlideState

var wall_buffer = 0.0

func _start_check(delta):
	return character.is_walled()

func _start(delta):
	if character.is_walled_right():
		character.direction_on_stick = 1
	else:
		character.direction_on_stick = -1
	wall_buffer = 0.075
	pass

func _update(delta):
	if !character.is_walled() || character.is_grounded():
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

func _stop_check(delta):
	return wall_buffer <= 0
