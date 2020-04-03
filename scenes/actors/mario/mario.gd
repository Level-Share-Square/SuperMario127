extends KinematicBody2D

class_name Character

signal died
signal state_changed

onready var states_node = $States
onready var animated_sprite = $Sprite

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

# Extra
export var is_wj_chained = false
export var real_friction = 0
export var current_jump = 0
export var jump_animation = 0
export var direction_on_stick = 1
export var rotating = true
export var spawn_pos = Vector2(0, 0)

export var disable_movement = false
export var disable_turning = false
export var disable_animation = false

export var attacking = false

export var player_id = 0

# States
var state = null
var last_state = null
export var controllable = true
export var dead = false
export var dive_cooldown = 0

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

export var mario_sounds : String
export var luigi_sounds : String

export var luigi_accel : float
export var luigi_fric : float
export var luigi_speed : float

# Inputs
export var left = false
export var left_just_pressed = false

export var right = false
export var right_just_pressed = false

export var jump = false
export var jump_just_pressed = false

export var dive = false
export var dive_just_pressed = false

export var spin = false
export var spin_just_pressed = false

export var gp = false
export var gp_just_pressed = false

export var gp_cancel = false
export var gp_cancel_just_pressed = false

export var controlled_locally = true

export var rotating_jump = false

#onready var global_vars_node = get_node("../GlobalVars")
#onready var level_settings_node = get_node("../LevelSettings")
onready var collision_shape = $Collision
onready var collision_raycast = $GroundCollision
onready var ground_check = $GroundCheck
onready var dive_collision_shape = $GroundCollisionDive
onready var player_collision = $PlayerCollision
onready var player_collision_shape = $PlayerCollision/CollisionShape2D
onready var sprite = $Sprite

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

slave func sync(pos, vel, sprite_frame, sprite_animation, sprite_rotation, is_attacking, is_dead, is_controllable, collision_disabled, dive_collision_disabled):
	next_position = pos
	velocity = vel
	sprite.animation = sprite_animation
	sprite.frame = sprite_frame
	sprite.rotation_degrees = sprite_rotation
	attacking = is_attacking
	dead = is_dead
	controllable = is_controllable
	collision_shape.disabled = collision_disabled
	dive_collision_shape.disabled = dive_collision_disabled

func load_in(level_data : LevelData, level_area : LevelArea):
	level_size = level_area.settings.size
	for exception in collision_exceptions:
		add_collision_exception_with(get_node(exception))
	player_collision.connect("body_entered", self, "player_hit")
		
	if character == 0:
		var sound_scene = load(mario_sounds)
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
		var sound_scene = load(luigi_sounds)
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

func is_grounded():
	ground_check.force_raycast_update()
	return ground_check.is_colliding() and velocity.y >= 0

func is_ceiling():
	return test_move(self.transform, Vector2(0, -0.1)) and collided_last_frame

func is_walled():
	return (is_walled_left() or is_walled_right()) and collided_last_frame

func is_walled_left():
	return test_move(self.transform, Vector2(-0.1, 1)) and collided_last_frame

func is_walled_right():
	return test_move(self.transform, Vector2(0.1, 1)) and collided_last_frame

func hide():
	visible = false
	velocity = Vector2(0, 0)
	position = initial_position

func show():
	visible = true

func set_state(state, delta: float):
	last_state = self.state
	self.state = null
	if last_state != null:
		last_state._stop(delta)
	if state != null:
		self.state = state
		state._start(delta)
	emit_signal("state_changed", state, last_state)

func get_state_node(name: String):
	if states_node.has_node(name):
		return states_node.get_node(name)

func set_state_by_name(name: String, delta: float):
	if get_state_node(name) != null:
		set_state(get_state_node(name), delta)
		
func player_hit(body):
	if body.name.begins_with("Character"):
		if global_position.y + 8 < body.global_position.y:
			velocity.y = -230
			#body.stomped_sound_player.play() -Felt weird without animations
			if state != get_state_node("DiveState"):
				set_state_by_name("BounceState", 0)
		elif global_position.y - 8 > body.global_position.y:
			velocity.y = 150
		elif global_position.x < body.global_position.x:
			if body.attacking == true and !attacking:
				velocity.x = -205
				velocity.y = -175
				body.velocity.x = 250
				set_state_by_name("BonkedState", 0)
				sound_player.play_hit_sound()
			elif !attacking or (body.attacking and attacking):
				velocity.x = -250
				body.velocity.x = 250
		elif global_position.x > body.global_position.x:
			if body.attacking == true and !attacking:
				velocity.x = 205
				velocity.y = -175
				body.velocity.x = -250
				set_state_by_name("BonkedState", 0)
				sound_player.play_hit_sound()
			elif !attacking or (body.attacking and attacking):
				velocity.x = 250
				body.velocity.x = -250

func _process(delta: float):
	if next_position:
		position = position.linear_interpolate(next_position, delta * sync_interpolation_speed)

func _physics_process(delta: float):
	var gravity = 7.82 #global_vars_node.gravity
	# Gravity
	velocity += gravity * Vector2(0, gravity_scale)
	
	if (state == null or !state.override_rotation) and !rotating_jump:
		
		var sprite_rotation = 0
		
		if is_grounded():
			var normal = ground_check.get_collision_normal()
			sprite_rotation = atan2(normal.y, normal.x) + (PI/2)
			
		if is_grounded():
			velocity.y += abs(sprite_rotation) * 100 # this is required to keep mario from falling off slopes
			
		sprite.rotation = lerp(sprite.rotation, sprite_rotation, delta * rotation_interpolation_speed)
			
	# Inputs
	if controlled_locally:
		if controllable and !FocusCheck.is_ui_focused:
			var control_id = player_id
			if PlayerSettings.other_player_id != -1 or number_of_players == 1:
				control_id = PlayerSettings.control_mode
			if Input.is_action_pressed("move_left_" + str(control_id)) and !Input.is_blocking_signals():
				left = true
			else:
				left = false
			if Input.is_action_just_pressed("move_left_" + str(control_id)):
				left_just_pressed = true
			else:
				left_just_pressed = false
				
			if Input.is_action_pressed("move_right_" + str(control_id)):
				right = true
			else:
				right = false
			if Input.is_action_just_pressed("move_right_" + str(control_id)):
				right_just_pressed = true
			else:
				right_just_pressed = false
				
			if Input.is_action_pressed("jump_" + str(control_id)):
				jump = true
			else:
				jump = false
			if Input.is_action_just_pressed("jump_" + str(control_id)):
				jump_just_pressed = true
			else:
				jump_just_pressed = false
				
			if Input.is_action_pressed("dive_" + str(control_id)):
				dive = true
			else:
				dive = false
			if Input.is_action_just_pressed("dive_" + str(control_id)):
				dive_just_pressed = true
			else:
				dive_just_pressed = false
				
			if Input.is_action_pressed("spin_" + str(control_id)):
				spin = true
			else:
				spin = false
			if Input.is_action_just_pressed("spin_" + str(control_id)):
				spin_just_pressed = true
			else:
				spin_just_pressed = false
				
			if Input.is_action_pressed("ground_pound_" + str(control_id)):
				gp = true
			else:
				gp = false
			if Input.is_action_just_pressed("ground_pound_" + str(control_id)):
				gp_just_pressed = true
			else:
				gp_just_pressed = false
				
			if Input.is_action_pressed("ground_pound_cancel_" + str(control_id)):
				gp_cancel = true
			else:
				gp_cancel = false
			if Input.is_action_just_pressed("ground_pound_cancel_" + str(control_id)):
				gp_cancel_just_pressed = true
			else:
				gp_cancel_just_pressed = false
		else:
			left = false
			left_just_pressed = false
			
			right = false
			right_just_pressed = false
			
			jump = false
			jump_just_pressed = false
			
			dive = false
			dive_just_pressed = false
			
			spin = false
			spin_just_pressed = false
	
	if state != null:
		disable_movement = state.disable_movement
		disable_turning = state.disable_turning
		disable_animation = state.disable_animation
	else:
		disable_movement = false
		disable_turning = false
		disable_animation = false
	# Movement
	move_direction = 0
	if left and disable_movement == false:
		move_direction = -1
	elif right and disable_movement == false:
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

			if !disable_animation and controlled_locally:
				if !test_move(transform, Vector2(velocity.x * delta, 0)):
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
				if (abs(velocity.x) > move_speed):
					sprite.speed_scale = abs(velocity.x) / move_speed
				else:
					sprite.speed_scale = 1
		else:
			if ((velocity.x < move_speed and move_direction == 1) or (velocity.x > -move_speed and move_direction == -1)):
				velocity.x += aerial_acceleration * move_direction
			elif ((velocity.x > move_speed and move_direction == 1) or (velocity.x < -move_speed and move_direction == -1)):
				velocity.x -= 0.25 * move_direction
			if !disable_turning:
				facing_direction = move_direction
	else:
		if (velocity.x > 0):
			if (velocity.x > 15):
				if (is_grounded()):
					velocity.x -= friction
				else:
					velocity.x -= aerial_friction
			else:
				velocity.x = 0
		elif (velocity.x < 0):
			if (velocity.x < -15):
				if (is_grounded()):
					velocity.x += friction
				else:
					velocity.x += aerial_friction
			else:
				velocity.x = 0

		if !disable_animation and controlled_locally:
			if is_grounded():
				if facing_direction == 1:
					sprite.animation = "idleRight"
				else:
					sprite.animation = "idleLeft"
				sprite.speed_scale = 1

	if PlayerSettings.other_player_id == -1 or PlayerSettings.my_player_index == player_id:
		for state_node in states_node.get_children():
			state_node.handle_update(delta)

	if state != null:
		if state.disable_snap:
			snap = Vector2()
		else:
			snap = Vector2(0, 32)
	else:
		snap = Vector2(0, 32)

	# Move by velocity
	velocity = move_and_slide_with_snap(velocity, snap, Vector2.UP, true, 4, deg2rad(46))
	var slide_count = get_slide_count()
	if slide_count > 0:
		collided_last_frame = true
	else:
		collided_last_frame = false

	# Boundaries
	if position.y > (level_size.y * 32) + 128:
		if PlayerSettings.other_player_id == -1 or PlayerSettings.my_player_index == player_id:
			kill("fall")
	if position.x < 0:
		position.x = 0
		velocity.x = 0
		if is_grounded() and move_direction != 0 and !disable_animation and controlled_locally:
			if facing_direction == 1:
				sprite.animation = "idleRight"
			else:
				sprite.animation = "idleLeft"
	if position.x > level_size.x * 32:
		position.x = level_size.x * 32
		velocity.x = 0
		if is_grounded() and move_direction != 0 and !disable_animation and controlled_locally:
			if facing_direction == 1:
				sprite.animation = "idleRight"
			else:
				sprite.animation = "idleLeft"
	last_velocity = velocity
	last_move_direction = move_direction
	
	if PlayerSettings.other_player_id != -1:
		if player_id == PlayerSettings.my_player_index and is_network_master():
			rpc_unreliable("sync", position, velocity, sprite.frame, sprite.animation, sprite.rotation_degrees, attacking, dead, controllable, collision_shape.disabled, dive_collision_shape.disabled)
	
func kill(cause):
	if !dead:
		dead = true
		var reload = true
		emit_signal("dead")
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
				position = spawn_pos
				dead = false
				reload = false
				controllable = true
				set_state_by_name("FallState", 0)
		elif cause == "reload":
			transition_time = 0.4
		if reload:
			scene_transitions.reload_scene(cutout_in, cutout_out, transition_time)

func exit():
	mode_switcher.get_node("ModeSwitcherButton").switch()
