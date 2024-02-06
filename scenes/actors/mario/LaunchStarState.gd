extends State

class_name LaunchStarState

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	priority = 6
	blacklisted_states = []
	disable_movement = true
	disable_turning = true
	disable_friction = true
	disable_animation = true
	override_rotation = true
	use_dive_collision = true
	auto_flip = true

func _start_check(_delta):
	pass

func _start(_delta):
	pass
