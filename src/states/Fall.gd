extends State

class_name FallState
	
func _startCheck(delta):
	return character.velocity.y > 0 && !character.isGrounded() && character.state != character.getStateInstance("Dive")

func _start(delta):
	pass

func _update(delta):
	var sprite = character.get_node("AnimatedSprite")
	if character.facingDirection == 1:
		sprite.animation = "fallRight"
	else:
		sprite.animation = "fallLeft"

func _stop(delta):
	pass

func _stopCheck(delta):
	return character.isGrounded()

func _generalUpdate(delta):
	pass
