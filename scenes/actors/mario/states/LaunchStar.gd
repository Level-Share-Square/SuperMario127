extends State

class_name LaunchStarState

var old_gravity_scale = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	priority = 10
	blacklisted_states = ["FallState", "WallSlideState", "WallJumpState", "SpinningState", "DiveState", "SlideState", "SlideStopState", "BackflipState", "BonkedState", "SquishedState", "LavaBoostState", "KnockbackState", "GetupState", "BounceState", "GroundPoundStartState", "GroundPoundEndState", "GroundPoundState", "ButtSlideState", "RainbowStarState", "RainbowStarWindupState", "WingMarioState", "SwimmingState"]
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
	print("starting")
	old_gravity_scale = character.gravity_scale
	character.gravity_scale = 0
	character.sprite.animation = "spinning"
	character.sprite.speed_scale = 1.5
	character.camera.set_zoom(Vector2(1.5, 1.5))
	
func _stop(_delta):
	print("stopping")
	
	character.gravity_scale = old_gravity_scale
	character.camera.set_zoom(Vector2(1, 1))
	character.camera.auto_move = true
	var new_state = character.get_state_node("SpinningState")
	character.state = new_state
	character.emit_signal("state_changed", self, new_state)
	new_state._start(_delta)
#	new_state.override = true
	if(character.velocity.x < 0):
		character.anim_player.play("triple_jump")
	else:
		character.anim_player.play("triple_jump_right")
	
	
	
