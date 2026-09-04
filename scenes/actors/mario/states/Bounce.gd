extends State

class_name BounceState

func _ready():
	priority = 1
	blacklisted_states = ["DiveState", "SlideState", "GetupState"]

func _start_check(_delta):
	return false

func _start(_delta):
	if is_instance_valid(character.nozzle) and character.nozzle.activated: return
	LastInputDevice.rumble(0.5, 0.0, 0.05)

func _update(_delta):
	var sprite = character.sprite
	if character.velocity.y < 0 and !character.is_grounded():
		if character.facing_direction == 1:
			sprite.animation = "jumpRight"
		else:
			sprite.animation = "jumpLeft"

func _stop_check(_delta):
	return character.velocity.y > 0
