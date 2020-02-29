extends State

class_name SpinningState

export var boost_power: float = 5
export var gravity_scale: float = 0.5
var old_gravity_scale = 1
var can_boost = true

func _start_check(delta):
	return Input.is_action_just_pressed("spin") && character.state != character.get_state_instance("Dive") && character.state != character.get_state_instance("WallSlide") and character.state != character.get_state_instance("Bonked") && !character.is_grounded()

func _start(delta):
	if can_boost == true && !character.is_grounded():
		can_boost = false
		if character.velocity.y > 0:
			character.velocity.y -= boost_power
	old_gravity_scale = character.gravity_scale
	character.gravity_scale = gravity_scale
	
func _update(delta):
	var sprite = character.get_node("AnimatedSprite")
	if sprite.animation != "spinning":
		sprite.animation = "spinning"
	if character.velocity.y < 0:
		character.gravity_scale = old_gravity_scale
	else:
		character.gravity_scale = gravity_scale
		
func _stop(delta):
	character.gravity_scale = old_gravity_scale

func _stop_check(delta):
	return !Input.is_action_pressed("spin") or character.is_grounded()
	
func _general_update(delta):
	if character.is_grounded():
		can_boost = true
