extends KinematicBody2D

class_name Character

signal state_changed

onready var states_node = $States
onready var nozzles_node = $Nozzles
onready var animated_sprite = $Sprite
onready var anim_player = $AnimationPlayer

onready var spotlight = $Spotlight

# Cutout
export var cutout_death : StreamTexture
export var cutout_circle : StreamTexture

# Basic Physics
export var initial_position := Vector2(0, 0)
export var velocity := Vector2(0, 0)
var last_velocity := Vector2(0, 0)

export var gravity_scale = 1
export var facing_direction = 1
export var move_direction = 0
export var last_move_direction = 0

export var move_speed = 216.0
export var acceleration = 7.5
export var deceleration = 15.0
export var aerial_acceleration = 7.5
export var friction = 10.5
export var aerial_friction = 1.15

# Sounds
var sound_player
var footstep_interval = 0

# Extra
export var is_wj_chained = false
export var real_friction = 0
export var current_jump = 0
export var jump_animation = 0
export var direction_on_stick = 1
export var rotating = true
export var spawn_pos = Vector2(0, 0)
export var gravity : float

export var disable_movement = false
export var disable_turning = false
export var disable_friction = false
export var disable_animation = false

export var attacking = false
export var big_attack = false
export var heavy = false

export var player_id = 0

# States
var state = null
var last_state = null
var switching_state = false
export var controllable = true
export var invulnerable = false
export var invulnerable_frames = 0
export var movable = true
export var dead = false
export var stomping = false
export var dive_cooldown = 0

export var health := 8
export var health_shards := 0
var nozzle = null
var fuel := 100.0
var stamina := 100.0
var nozzles_list_index := 0

# Collision vars
var collision_down
var collision_up
var collision_left
var collision_right
var collided_last_frame = false

export var snap := Vector2(0, 32)

export(Array, NodePath) var collision_exceptions = []

# Character vars
export var character := 0

export var mario_frames : SpriteFrames
export var luigi_frames : SpriteFrames

export var mario_alt_frames : SpriteFrames
export var luigi_alt_frames : SpriteFrames

export var mario_collision : RectangleShape2D
export var mario_collision_offset : Vector2
export var mario_dive_collision : RectangleShape2D
export var mario_dive_collision_offset : Vector2

export var luigi_collision : RectangleShape2D
export var luigi_collision_offset : Vector2
export var luigi_dive_collision : RectangleShape2D
export var luigi_dive_collision_offset : Vector2

export var luigi_accel : float
export var luigi_fric : float
export var luigi_speed : float

# Inputs 
# First parameter is "pressed",
# second parameter is "just_pressed", 
# and third parameter is the input name.
export var inputs = [
	[false, false, "move_left_"], # Index 0
	[false, false, "move_right_"], # Index 1
	[false, false, "jump_"], # Index 2
	[false, false, "dive_"], # Index 3
	[false, false, "spin_"], # Index 4
	[false, false, "ground_pound_"], # Index 5
	[false, false, "ground_pound_cancel_"], # Index 6
	[false, false, "use_fludd_"], # Index 7
	[false, false, "switch_nozzles_"], # Index 8
	[false, false, "crouch_"], # Index 9
	[false, false, "pipe_down_"] # Index 10
]

export var controlled_locally = true

export var rotating_jump = false

#onready var global_vars_node = get_node("../GlobalVars")
#onready var level_settings_node = get_node("../LevelSettings")
onready var collision_shape = $Collision
onready var collision_raycast = $GroundCollision
onready var ground_check = $GroundCheck
onready var slope_stop_check = $SlopeStopCheck
onready var ground_check_dive = $GroundCheckDive
onready var left_check = $LeftCheck
onready var right_check = $RightCheck
onready var left_collision = $LeftCollision
onready var right_collision = $RightCollision
onready var dive_collision_shape = $GroundCollisionDive
onready var player_collision = $PlayerCollision
onready var player_collision_shape = $PlayerCollision/CollisionShape2D
onready var sprite = $Sprite
onready var fludd_sprite = $Sprite/Fludd
onready var water_sprite = $Sprite/Water
onready var water_sprite_2 = $Sprite/Water2
onready var fludd_sound = $FluddSound
onready var nozzle_switch_sound = $NozzleSwitchSound
onready var particles = $Particles2D
onready var slide_particles = $SlideParticles
onready var gp_particles1 = $GPParticles1
onready var gp_particles2 = $GPParticles2
onready var platform_detector = $PlatformDetector
onready var bottom_pos = $BottomPos
export var bottom_pos_offset : Vector2
export var bottom_pos_dive_offset : Vector2

var level_size = Vector2(80, 30)
var number_of_players = 2

var next_position : Vector2
var sync_interpolation_speed = 20
export var rotation_interpolation_speed = 15

#rpc_unreliable("update_inputs", 
#left, left_just_pressed,
#right, right_just_pressed,
#jump, jump_just_pressed,
#dive, dive_just_pressed,
#spin, spin_just_pressed
#)

puppet func sync(pos, vel, sprite_frame, sprite_animation, sprite_rotation, is_attacking, is_big_attacking, is_heavy, is_dead, is_controllable): # Ok slave
	next_position = pos
	velocity = vel
	sprite.animation = sprite_animation
	sprite.frame = sprite_frame
	sprite.rotation_degrees = sprite_rotation
	attacking = is_attacking
	big_attack = is_big_attacking
	heavy = is_heavy
	dead = is_dead
	controllable = is_controllable
	
func is_character():
	return true
	
func exploded(explosion_pos : Vector2):
	damage_with_knockback(explosion_pos, 2)
		
func damage_with_knockback(hit_pos : Vector2, amount : int = 1, cause : String = "hit", frames : int = 180):
	if !invulnerable:
		var direction = 1
		if (global_position - hit_pos).normalized().x < 0:
			direction = -1
		velocity.x = direction * 235
		velocity.y = -225
		set_state_by_name("KnockbackState", 0)
		damage(amount, cause, frames)

func load_in(level_data : LevelData, level_area : LevelArea):
	level_size = level_area.settings.size
	for exception in collision_exceptions:
		add_collision_exception_with(get_node(exception))
	var _connect = player_collision.connect("body_entered", self, "player_hit")
		
	if character == 0:
		var sound_scene = MiscCache.mario_sounds
		sound_player = sound_scene.instance()
		add_child(sound_player)
		if PlayerSettings.player1_character != PlayerSettings.player2_character or player_id == 0:
			sprite.frames = mario_frames
		else:
			sprite.frames = mario_alt_frames
		#collision_shape.position = mario_collision_offset
		#collision_shape.shape = mario_collision
		#player_collision_shape.position = mario_collision_offset
		#player_collision_shape.shape = mario_collision
		#dive_collision_shape.shape = mario_dive_collision
		#dive_collision_shape.position = mario_dive_collision_offset
		real_friction = friction
	else:
		var sound_scene = MiscCache.luigi_sounds
		sound_player = sound_scene.instance()
		add_child(sound_player)
		if PlayerSettings.player1_character != PlayerSettings.player2_character or player_id == 0:
			sprite.frames = luigi_frames
		else:
			sprite.frames = luigi_alt_frames
		#collision_shape.position = luigi_collision_offset
		#collision_shape.shape = luigi_collision
		#player_collision_shape.position = luigi_collision_offset
		#player_collision_shape.shape = luigi_collision
		#dive_collision_shape.shape = luigi_dive_collision
		#dive_collision_shape.position = luigi_dive_collision_offset
		move_speed = luigi_speed
		acceleration = luigi_accel
		friction = luigi_fric
		real_friction = luigi_fric
	collision_shape.disabled = false
	collision_raycast.disabled = false
	left_collision.disabled = false
	right_collision.disabled = false
	gravity = level_area.settings.gravity

func is_grounded():
	var raycast_node = ground_check
	if !dive_collision_shape.disabled:
		raycast_node = ground_check_dive
	raycast_node.force_raycast_update()
	return raycast_node.is_colliding() and velocity.y >= 0

func is_ceiling():
	return test_move(self.transform, Vector2(0, -0.1)) and collided_last_frame

func is_walled():
	return (is_walled_left() or is_walled_right()) and collided_last_frame

func is_walled_left():
	return test_move(self.transform, Vector2(-0.5, 1)) and test_move(self.transform, Vector2(-0.5, -1)) and collided_last_frame

func is_walled_right():
	return test_move(self.transform, Vector2(0.5, 1)) and test_move(self.transform, Vector2(0.5, -1)) and collided_last_frame

func hide():
	visible = false
	velocity = Vector2(0, 0)
	position = initial_position

func show():
	visible = true

func set_state(new_state, delta: float):
	last_state = state
	state = null
	if last_state != null:
		last_state._stop(delta)
	if new_state != null:
		state = new_state
		new_state._start(delta)
	emit_signal("state_changed", new_state, last_state)

func get_state_node(name: String):
	if states_node.has_node(name):
		return states_node.get_node(name)

func set_state_by_name(name: String, delta: float):
	if get_state_node(name) != null:
		set_state(get_state_node(name), delta)
		
func add_nozzle(new_nozzle):
	if !new_nozzle in CurrentLevelData.level_data.vars.nozzles_collected:
		CurrentLevelData.level_data.vars.nozzles_collected.append(new_nozzle)
		
func get_nozzle_node(name: String):
	if nozzles_node.has_node(name):
		return nozzles_node.get_node(name)
		
func set_nozzle(new_nozzle, change_index = true):
	fludd_sound.stop()
	nozzle = get_nozzle_node(str(new_nozzle))
	if change_index:
		nozzles_list_index = CurrentLevelData.level_data.vars.nozzles_collected.count(str(new_nozzle))
		
func player_hit(body):
	if body.name.begins_with("Character"):
		if !body.big_attack and !big_attack:
			if global_position.y + 8 < body.global_position.y:
				velocity.y = -230
				#body.stomped_sound_player.play() -Felt weird without animations
				if state != get_state_node("DiveState") and state != get_state_node("GroundPoundState") and state != get_state_node("GroundPoundStartState") and state != get_state_node("GroundPoundEndState"):
					set_state_by_name("BounceState", 0)
			elif global_position.y - 8 > body.global_position.y:
				velocity.y = 150
			elif global_position.x < body.global_position.x:
				if body.attacking == true and !attacking:
					velocity.x = -205
					velocity.y = -175
					body.velocity.x = 250
					set_state_by_name("KnockbackState", 0)
					sound_player.play_hit_sound()
				elif !attacking or (body.attacking and attacking):
					velocity.x = -250
					body.velocity.x = 250
			elif global_position.x > body.global_position.x:
				if body.attacking == true and !attacking:
					velocity.x = 205
					velocity.y = -175
					body.velocity.x = -250
					set_state_by_name("KnockbackState", 0)
					sound_player.play_hit_sound()
				elif !attacking or (body.attacking and attacking):
					velocity.x = 250
					body.velocity.x = -250
		elif !big_attack:
			if global_position.x < body.global_position.x:
				velocity.x = -205
				velocity.y = -175
				body.velocity.x = 250
				set_state_by_name("KnockbackState", 0)
				sound_player.play_hit_sound()
			else:
				velocity.x = 205
				velocity.y = -175
				body.velocity.x = -250
				set_state_by_name("KnockbackState", 0)
				sound_player.play_hit_sound()

func _process(delta: float):
	if invulnerable_frames > 0:
		visible = !visible
	elif invulnerable_frames == 0:
		visible = true
	if next_position:
		position = position.linear_interpolate(next_position, delta * sync_interpolation_speed)

func damage(amount : int = 1, cause : String = "hit", frames : int = 180):
	if !dead:
		invulnerable = true if frames != 0 else false
		invulnerable_frames = frames
		health -= amount
		if health <= 0:
			kill(cause)
		else:
			sound_player.play_hit_sound()
			
func heal(shards : int = 1):
	if !dead and health != 8:
		health_shards += shards
		health += floor(health_shards / 5)
		health_shards = health_shards % 5

func _physics_process(delta: float):
	bottom_pos.position = bottom_pos_offset
	if !dive_collision_shape.disabled:
		bottom_pos.position = bottom_pos_dive_offset
	var is_in_platform = false
	for body in platform_detector.get_overlapping_areas():
		if body.has_method("is_platform_area"):
			is_in_platform = body.is_platform_area()
	
	if invulnerable_frames > 0:
		invulnerable_frames -= 1
		invulnerable = true
	elif invulnerable_frames == 0:
		invulnerable = false
	
	# Gravity
	velocity += gravity * Vector2(0, gravity_scale)
	
	if movable and (state == null or !state.override_rotation) and (!is_instance_valid(nozzle) or !nozzle.override_rotation) and !rotating_jump and last_state != get_state_node("SlideState"):
		
		var sprite_rotation = 0
		var sprite_offset = Vector2()
		if is_grounded():
			var normal = ground_check.get_collision_normal()	
			sprite_rotation = atan2(normal.y, normal.x) + (PI/2)
			sprite_offset = Vector2(rad2deg(sprite_rotation) / 10, -abs(rad2deg(sprite_rotation) / 10))
			
		if is_grounded():
			velocity.y += abs(sprite_rotation) * 100 # this is required to keep mario from falling off slopes
		sprite.offset = sprite.offset.linear_interpolate(sprite_offset, delta * rotation_interpolation_speed)
		sprite.rotation = lerp_angle(sprite.rotation, sprite_rotation, delta * rotation_interpolation_speed)
		sprite.rotation_degrees = wrapf(sprite.rotation_degrees, -180, 180)
			
	# Inputs
	if controlled_locally:
		if controllable and !FocusCheck.is_ui_focused:
			var control_id = player_id
			if PlayerSettings.other_player_id != -1 or number_of_players == 1:
				control_id = PlayerSettings.control_mode
			for input in inputs:
				var input_id = input[2]
				
				if Input.is_action_pressed(input_id + str(control_id)):
					input[0] = true
				else:
					input[0] = false
				
				if Input.is_action_just_pressed(input_id + str(control_id)):
					input[1] = true
				else:
					input[1] = false
		else:
			for input in inputs:
				input[0] = false
				input[1] = false
	
	if state != null:
		disable_movement = state.disable_movement
		disable_turning = state.disable_turning
		disable_animation = state.disable_animation
		disable_friction = state.disable_friction
	else:
		disable_movement = false
		disable_turning = false
		disable_animation = false
		disable_friction = false
	# Movement
	move_direction = 0
	if inputs[0][0] and !inputs[1][0] and disable_movement == false:
		move_direction = -1
	elif inputs[1][0] and !inputs[0][0] and disable_movement == false:
		move_direction = 1
		
	if move_direction != 0:
		if is_grounded():
			if ((velocity.x > 0 and move_direction == -1) or (velocity.x < 0 and move_direction == 1)):
				velocity.x += deceleration * move_direction
			elif ((velocity.x < move_speed and move_direction == 1) or (velocity.x > -move_speed and move_direction == -1)):
				velocity.x += acceleration * move_direction
			elif ((velocity.x > move_speed and move_direction == 1) or (velocity.x < -move_speed and move_direction == -1)):
				velocity.x -= 3.5 * move_direction
			facing_direction = move_direction

			if !disable_animation and movable and controlled_locally:
				if !is_walled():
					if (abs(velocity.x) > move_speed):
						sprite.speed_scale = abs(velocity.x) / move_speed
					else:
						sprite.speed_scale = 1
					var animation_frame = sprite.frame
					if move_direction == 1:
						sprite.animation = "movingRight"
						if last_move_direction != move_direction:
							sprite.frame = animation_frame + 1
					else:
						sprite.animation = "movingLeft"
						if last_move_direction != move_direction:
							sprite.frame = animation_frame + 1
				else:
					if facing_direction == 1:
						sprite.animation = "idleRight"
					else:
						sprite.animation = "idleLeft"
					sprite.speed_scale = 0
				if footstep_interval <= 0 and sprite.speed_scale > 0:
					sound_player.play_footsteps()
					footstep_interval = clamp(0.8 - (sprite.speed_scale / 2.5), 0.1, 1)
				footstep_interval -= delta
		else:
			if ((velocity.x < move_speed and move_direction == 1) or (velocity.x > -move_speed and move_direction == -1)):
				velocity.x += aerial_acceleration * move_direction
			elif ((velocity.x > move_speed and move_direction == 1) or (velocity.x < -move_speed and move_direction == -1)):
				velocity.x -= 0.25 * move_direction
			if !disable_turning:
				facing_direction = move_direction
	elif !disable_friction:
		if (velocity.x > 0):
			if (velocity.x > 15):
				if (is_grounded()):
					velocity.x -= friction
				else:
					if abs(velocity.x) > move_speed:
						velocity.x -= aerial_friction*2
					else:
						velocity.x -= aerial_friction
			else:
				velocity.x = 0
		elif (velocity.x < 0):
			if (velocity.x < -15):
				if (is_grounded()):
					velocity.x += friction
				else:
					if abs(velocity.x) > move_speed:
						velocity.x += aerial_friction*2
					else:
						velocity.x += aerial_friction
			else:
				velocity.x = 0

		if !disable_animation and movable and controlled_locally:
			if is_grounded():
				if facing_direction == 1:
					sprite.animation = "idleRight"
				else:
					sprite.animation = "idleLeft"
				sprite.speed_scale = 1

	if PlayerSettings.other_player_id == -1 or PlayerSettings.my_player_index == player_id:
		for state_node in states_node.get_children():
			state_node.handle_update(delta)
			
		for nozzle_node in nozzles_node.get_children():
			nozzle_node.handle_update(delta)

	if state != null:
		if state.disable_snap:
			snap = Vector2()
		elif (left_check.is_colliding() or right_check.is_colliding()) and velocity.y > 0:
			var normal = ground_check.get_collision_normal()
			if normal.x == 0:
				snap = Vector2(0, 12)
			else:
				snap = Vector2(0, 20)
		else:
			snap = Vector2()
	else:
		if (left_check.is_colliding() or right_check.is_colliding()) and velocity.y > 0:
			var normal = ground_check.get_collision_normal()
			if normal.x == 0:
				snap = Vector2(0, 12)
			else:
				snap = Vector2(0, 20)
		else:
			snap = Vector2()
	if is_in_platform:
		snap = Vector2()
			
	if inputs[8][1] and CurrentLevelData.level_data.vars.nozzles_collected.size() > 1:
		nozzles_list_index += 1
		if nozzles_list_index >= CurrentLevelData.level_data.vars.nozzles_collected.size():
			nozzles_list_index = 0
		
		var new_nozzle = str(CurrentLevelData.level_data.vars.nozzles_collected[nozzles_list_index])
		set_nozzle(new_nozzle, false)
		
		nozzle_switch_sound.play()
		print(CurrentLevelData.level_data.vars.nozzles_collected)
		
	if is_instance_valid(nozzle):
		fludd_sprite.visible = true
		water_sprite.visible = true
		water_sprite_2.visible = true
		water_sprite_2.flip_h = water_sprite.flip_h
		water_sprite_2.animation = water_sprite.animation
		water_sprite_2.frame = water_sprite_2.frame
		if character == 0:
			fludd_sprite.frames = nozzle.frames
		else:
			fludd_sprite.frames = nozzle.frames_luigi
		fludd_sprite.animation = sprite.animation
		fludd_sprite.frame = sprite.frame
		
		if character == 0:
			if sprite.animation in nozzle.animation_water_positions:
				water_sprite.position = nozzle.animation_water_positions[sprite.animation]
			else:
				if facing_direction == 1:
					water_sprite.position = nozzle.fallback_water_pos_right
				else:
					water_sprite.position = nozzle.fallback_water_pos_left
		else:
			if sprite.animation in nozzle.animation_water_positions_luigi:
				water_sprite.position = nozzle.animation_water_positions_luigi[sprite.animation]
			else:
				if facing_direction == 1:
					water_sprite.position = nozzle.fallback_water_pos_right_luigi
				else:
					water_sprite.position = nozzle.fallback_water_pos_left_luigi
					
		water_sprite_2.position = water_sprite.position - Vector2(-5 * facing_direction, 2)
	else:
		fludd_sprite.visible = false
		water_sprite.visible = false
		water_sprite_2.visible = false

	# Move by velocity
	if movable:
		velocity = move_and_slide_with_snap(velocity, snap, Vector2.UP, true, 4, deg2rad(46))
		var slide_count = get_slide_count()
		if slide_count > 0:
			collided_last_frame = true
		else:
			collided_last_frame = false
	else:
		collided_last_frame = false

	# Boundaries
	if position.y > (level_size.y * 32) + 128:
		if PlayerSettings.other_player_id == -1 or PlayerSettings.my_player_index == player_id:
			kill("fall")
	if position.x < 0:
		position.x = 0
		velocity.x = 0
	if position.x > level_size.x * 32:
		position.x = level_size.x * 32
		velocity.x = 0
	last_velocity = velocity
	last_move_direction = move_direction
	
	if PlayerSettings.other_player_id != -1:
		if player_id == PlayerSettings.my_player_index and is_network_master():
			rpc_unreliable("sync", position, velocity, sprite.frame, sprite.animation, sprite.rotation_degrees, attacking, big_attack, heavy, dead, controllable)
	
func switch_areas(area_id, transition_time):
	scene_transitions.reload_scene(cutout_circle, cutout_circle, transition_time, area_id)
	
func kill(cause):
	if !dead:
		dead = true
		var reload = true
		var cutout_in = cutout_circle
		var cutout_out = cutout_circle
		var transition_time = 0.75
		if cause == "fall":
			controllable = false
			sound_player.play_fall_sound()
			if number_of_players == 1:
				cutout_in = cutout_death
				yield(get_tree().create_timer(1), "timeout")
			else:
				yield(get_tree().create_timer(3), "timeout")
				position = spawn_pos - Vector2(0, 16)
				dead = false
				reload = false
				controllable = true
				set_state_by_name("FallState", 0)
		elif cause == "reload":
			transition_time = 0.4
		elif cause == "green_demon":
			controllable = false
			cutout_in = cutout_death
		elif cause == "hit":
			controllable = false
			cutout_in = cutout_death
			sound_player.play_death_sound()
			transition_time = 1.6
			
		if reload:
			CurrentLevelData.level_data.vars.transition_data = []
			scene_transitions.reload_scene(cutout_in, cutout_out, transition_time, 0)

func exit():
	mode_switcher.get_node("ModeSwitcherButton").switch()
