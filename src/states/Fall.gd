extends State

class_name FallState
	
func _start_check(delta):
	return character.velocity.y > 0 && !character.is_grounded() && character.state != character.get_state_instance("Dive") && character.state != character.get_state_instance("WallSlide") and character.state != character.get_state_instance("WallJump") and character.state != character.get_state_instance("Bonked")

func _start(delta):
	pass

func _update(delta):
	var sprite = character.get_node("AnimatedSprite")
	if character.facing_direction == 1:
		sprite.animation = "fallRight"
	else:
		sprite.animation = "fallLeft"

func _stop(delta):
	pass

func _stop_check(delta):
	return character.is_grounded()
