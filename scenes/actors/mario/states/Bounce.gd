extends State

class_name BounceState

func _ready():
	priority = 1
	blacklisted_states = ["DiveState", "SlideState", "GetupState"]

func _start_check(_delta):
	return false

func _update(_delta):
	var sprite = character.sprite
	if character.velocity.y < 0 and !character.is_grounded():
		if character.facing_direction == 1:
			sprite.animation = "jumpRight"
		else:
			sprite.animation = "jumpLeft"

func _stop_check(_delta):
	return character.velocity.y > 0
