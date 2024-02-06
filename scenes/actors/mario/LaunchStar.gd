extends State

class_name LaunchStarState

var old_gravity_scale = 1.0

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
	attack_tier = 2

func _start_check(_delta):
	pass

func _start(_delta):
	old_gravity_scale = character.gravity_scale
	character.gravity_scale = 0
	character.sprite.animation = "spinning"
	
func _stop(_delta):
	character.gravity_scale = old_gravity_scale
	
