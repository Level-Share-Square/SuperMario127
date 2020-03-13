extends State

class_name FallState
	
func _start_check(delta):
	return character.velocity.y > 0 && !character.is_grounded() && character.state != character.get_state_node("Dive") && character.state != character.get_state_node("WallSlide") and character.state != character.get_state_node("WallJump") and character.state != character.get_state_node("Bonked") and character.state != character.get_state_node("Spinning")

func _start(delta):
	pass

func _update(delta):
	var sprite = character.get_node("AnimatedSprite")
	if character.facing_direction == 1:
		if character.jump_animation == 0:
			sprite.animation = "fallRight"
		elif character.jump_animation == 1:
			sprite.animation = "doubleFallRight"
	else:
		if character.jump_animation == 0:
			sprite.animation = "fallLeft"
		elif character.jump_animation == 1:
			sprite.animation = "doubleFallLeft"

func _stop(delta):
	character.jump_animation = 0
	pass

func _stop_check(delta):
	return character.is_grounded()
