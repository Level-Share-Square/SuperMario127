extends KinematicBody2D

class_name Character

signal state_changed

onready var states_node = $States
onready var nozzles_node = $Nozzles
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
export var big_attack = false
export var heavy = false

export var player_id = 0

# States
var state = null
var last_state = null
export var controllable = true
export var dead = false
export var dive_cooldown = 0

var nozzle = null
var fuel := 100.0
var stamina := 100.0

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
	[false, false, "use_fludd_"] # Index 7
]

export var controlled_locally = true

export var rotating_jump = false

#onready var global_vars_node = get_node("../GlobalVars")
#onready var level_settings_node = get_node("../LevelSettings")
onready var collision_shape = $Collision
onready var collision_raycast = $GroundCollision
onready var ground_check = $GroundCheck
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

func load_in(_level_data : LevelData, level_area : LevelArea):
	nozzle = $Nozzles/HoverNozzle
	level_size = level_area.settings.size
	for exception in collision_exceptions:
		add_collision_exception_with(get_node(exception))
	var _connect = player_collision.connect("body_entered", self, "player_hit")
		
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
	collision_shape.disabled = false
	collision_raycast.disabled = false
	left_collision.disabled = false
	right_collision.disabled = false

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
	return test_move(self.transform, Vector2(-0.5, 1)) and collided_last_frame

func is_walled_right():
	return test_move(self.transform, Vector2(0.5, 1)) and collided_last_frame

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
		elif !big_attack:
			if global_position.x < body.global_position.x:
				velocity.x = -205
				velocity.y = -175
				body.velocity.x = 250
				set_state_by_name("BonkedState", 0)
				sound_player.play_hit_sound()
			else:
				velocity.x = 205
				velocity.y = -175
				body.velocity.x = -250
				set_state_by_name("BonkedState", 0)
				sound_player.play_hit_sound()

func _process(delta: float):
	if next_position:
		position = position.linear_interpolate(next_position, delta * sync_interpolation_speed)

func _physics_process(delta: float):
	var gravity = 7.82 #global_vars_node.gravity
	# Gravity
	velocity += gravity * Vector2(0, gravity_scale)
	
	if (state == null or !state.override_rotation) and (nozzle == null or !nozzle.override_rotation) and !rotating_jump and last_state != get_state_node("SlideState"):
		
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
	else:
		disable_movement = false
		disable_turning = false
		disable_animation = false
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
			
		for nozzle_node in nozzles_node.get_children():
			nozzle_node.handle_update(delta)

	if state != null:
		if state.disable_snap:
			snap = Vector2()
		elif !left_check.is_colliding() and !right_check.is_colliding() and velocity.y > 0:
			snap = Vector2(0, 32)
		else:
			snap = Vector2()
	else:
		if !left_check.is_colliding() and !right_check.is_colliding() and velocity.y > 0:
			snap = Vector2(0, 32)
		else:
			snap = Vector2()

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
			rpc_unreliable("sync", position, velocity, sprite.frame, sprite.animation, sprite.rotation_degrees, attacking, big_attack, heavy, dead, controllable)
	
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
		if reload:
			scene_transitions.reload_scene(cutout_in, cutout_out, transition_time)

func exit():
	mode_switcher.get_node("ModeSwitcherButton").switch()
