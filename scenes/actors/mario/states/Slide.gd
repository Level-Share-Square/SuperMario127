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

func _start(_delta):
	character.ground_shape.disabled = true
	if character.state != character.get_state_node("Jump"):
		character.friction = 8
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

func _update(_delta):
	var sprite = character.sprite
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
		
		sprite.rotation = lerp(sprite.rotation, sprite_rotation, fps_util.PHYSICS_DELTA * lerp_speed)
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
		character.ground_collider_enable_timer.start()
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
	if character.inputs[2][0]:
		getup_buffer = 0.075
	if character.inputs[9][1] and !(character.inputs[3][1] and abs(character.velocity.x) > 150 and character.is_grounded()) and abs(normal.x) <= 0.2:
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
		if is_instance_valid(character.sound_player):
			character.sound_player.set_skid_playing(false)
		character.particles.emitting = false
		
	if ledge_buffer > 0:
		if getup_buffer > 0:
			getup_buffer = 0
			ledge_buffer = 0
			var move_direction = 0
			if character.inputs[0][0]:
				move_direction -= 1
			if character.inputs[1][0]:
				move_direction += 1
			if (move_direction == 0 and !is_crouch) or move_direction == character.facing_direction:
				change_to_getup(delta)
			else:
				if !character.test_move(character.transform, Vector2(0, -16)):
					character.position.y -= 16
				character.get_state_node("JumpState").jump_buffer = 0
				character.set_state_by_name("BackflipState", delta)
			
		ledge_buffer -= delta
		if ledge_buffer < 0:
			ledge_buffer = 0
