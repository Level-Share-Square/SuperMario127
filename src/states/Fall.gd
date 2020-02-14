extends State

class_name FallState

onready var sprite = character.get_node("AnimatedSprite");
	
func _startCheck(delta):
	return character.velocity.y > 0 && !character.isGrounded();

func _start(delta):
	pass

func _update(delta):
	if character.facingDirection == 1:
		sprite.animation = "fallRight";
	else:
		sprite.animation = "fallLeft";

func _stopCheck(delta):
	return character.isGrounded();

func _generalUpdate(delta):
	pass
