extends State

class_name FallState
	
func _start_check(_delta):
	return character.velocity.y > 0 and !character.is_grounded()

func _start(_delta):
	pass

func _update(_delta):
	var sprite = character.sprite
	if character.facing_direction == 1:
		if character.jump_animation == 0:
			sprite.animation = "fallRight"
		elif character.jump_animation == 1:
			sprite.animation = "doubleFallRight"
	elif character.facing_direction == -1:
		if character.jump_animation == 0:
			sprite.animation = "fallLeft"
		elif character.jump_animation == 1:
			sprite.animation = "doubleFallLeft"

func _stop(_delta):
	character.jump_animation = 0

func _stop_check(_delta):
	return character.is_grounded()
