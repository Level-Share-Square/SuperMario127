extends State

class_name BounceState

func _ready():
	priority = 1
	blacklisted_states = ["DiveState", "SlideState", "GetupState"]

func _start_check(delta):
	return false

func _update(delta):
	var sprite = character.animated_sprite
	if character.velocity.y < 0 && !character.is_grounded():
		if character.facing_direction == 1:
			sprite.animation = "jumpRight"
		else:
			sprite.animation = "jumpLeft"

func _stop_check(delta):
	return character.velocity.y > 0
