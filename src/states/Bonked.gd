extends State

class_name BonkedState
export var bonk_direction: int = 1

func _start_check(delta):
	return false
	
func _start(delta):
	bonk_direction = character.facing_direction
	character.current_jump = 0

func _update(delta):
	var sprite = character.get_node("AnimatedSprite")
	if (bonk_direction == 1):
		sprite.animation = "bonkedRight"
	else:
		sprite.animation = "bonkedLeft"

func _stop_check(delta):
	return character.is_grounded()
