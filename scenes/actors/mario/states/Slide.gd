extends State

class_name SlideState

var is_crouch = false
var stop = false
var crouch_buffer = 0
var getup_buffer = 0
var ledge_buffer = 0

func _ready():
	priority = 4
	attack_tier = 1
	disable_turning = true
	disable_movement = true
	disable_animation = true
	disable_snap = false
	override_rotation = true
	use_dive_collision = true
	blacklisted_states = ["SlideStopState", "GroundPoundEndState", "ButtSlideState"]
	
func _start_check(_delta):
	return crouch_buffer > 0 and character.is_grounded()

func _start(delta):
	if character.state != character.get_state_node("Jump"):
		character.friction = 4
	if crouch_buffer > 0:
		is_crouch = true
		character.velocity.y = 120
	else:
		is_crouch = false
	if !is_crouch:
		character.sound_player.set_skid_playing(true)
	else:
		character.sound_player.play_duck_sound()
	#print(character.ground_check.get_collision_normal())

func _update(delta):
	var sprite = character.animated_sprite
	if (character.facing_direction == 1):
		sprite.animation = "diveRight"
	else:
		sprite.animation = "diveLeft"
		
	if abs(character.velocity.x) > 50 and character.is_grounded():
		character.particles.emitting = true
	else:
		character.particles.emitting = false
		
	if abs(character.velocity.x) > 50:
		attack_tier = 1
	else:
		attack_tier = 0
		
	if character.is_grounded() or is_crouch:
		var lerp_speed = character.rotation_interpolation_speed
		if is_crouch:
			lerp_speed = 15
		var normal = character.ground_check.get_collision_normal()
		var sprite_rotation = atan2(normal.y, normal.x) + (PI/2)
		sprite_rotation += PI/2 * character.facing_direction
		
		sprite.rotation = lerp(sprite.rotation, sprite_rotation, delta * lerp_speed)
	#elif is_crouch:
		#character.position.y += 2.5	

func _stop(delta):
	character.sound_player.set_skid_playing(false)
	character.particles.emitting = false
	character.friction = character.real_friction
	if character.is_grounded() and character.velocity.x < 5 and character.velocity.x > -5:
		character.set_state_by_name("SlideStopState", delta)
	else:
		character.position.y -= 5
		character.set_state_by_name("DiveState", delta)
	stop = false
	
func change_to_getup(delta):
	character.sound_player.set_skid_playing(false)
	character.particles.emitting = false
	character.set_state_by_name("GetupState", delta)
	if !character.test_move(character.transform, Vector2(0, -16)):
		character.position.y -= 16
	getup_buffer = 0
	ledge_buffer = 0

func _stop_check(_delta):
	return (abs(character.velocity.x) < 5 and !character.inputs[9][0]) or stop or (!character.is_grounded() and !is_crouch)

func _general_update(delta):
	var normal = character.ground_check.get_collision_normal()
	if character.inputs[2][1]:
		getup_buffer = 0.075
	if character.inputs[9][1] and abs(normal.x) <= 0.2:
		crouch_buffer = 0.15
	if getup_buffer > 0:
		getup_buffer -= delta
		if getup_buffer < 0:
			getup_buffer = 0
	if crouch_buffer > 0:
		crouch_buffer -= delta
		if crouch_buffer < 0:
			crouch_buffer = 0
			
	if character.is_grounded() and character.state == self:
		ledge_buffer = 0.125
		
	if character.state != self and character.state != character.get_state_node("WallSlideState") and character.state != character.get_state_node("ButtSlideState"):
		character.sound_player.set_skid_playing(false)
		character.particles.emitting = false
		
	if ledge_buffer > 0:
		if getup_buffer > 0:
			getup_buffer = 0
			ledge_buffer = 0
			if !is_crouch or ((character.move_direction == 0 or character.move_direction == character.facing_direction) and abs(character.velocity.x) > 50):
				change_to_getup(delta)
			else:
				character.position.y -= 16
				character.get_state_node("JumpState").jump_buffer = 0
				character.set_state_by_name("BackflipState", delta)
			
		ledge_buffer -= delta
		if ledge_buffer < 0:
			ledge_buffer = 0
