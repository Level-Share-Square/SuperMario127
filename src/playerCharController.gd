extends KinematicBody2D

class_name Character

export var init_pos = Vector2(0, 0)
export var velocity = Vector2(0, 0)
var last_velocity = Vector2(0, 0)
export var gravity_scale = 1
export var facing_direction = 1
export var move_direction = 0

export var move_speed = 216.0
export var acceleration = 7.5
export var deceleration = 25.0
export var air_accel = 7.5
export var friction = 10.5
export var air_fricc = 1.15
export var jump_power = 350.0
var old_friction = 10.5
var jump_playing = true
var current_jump = 0
var jump_animation = 0
export var real_friction = 0

var diving = false
var rotating = false
var sliding = false

export var walljump_power = Vector2(350, 320)
export var is_wj_chained = false
var direction_on_stick = 1

var state = null
var last_state = null
var controllable = true
export var state_names: PoolStringArray = []
var states = []
var state_map = {}

# Collision vars
var collision_down
var collision_up
var collision_left
var collision_right
var collided_last_frame = false


onready var global_vars_node = get_node("../GlobalVars")
onready var level_settings_node = get_node("../LevelSettings")
onready var collision_shape = get_node("CollisionShape2D")
onready var sprite = get_node("AnimatedSprite")
onready var jump_player = get_node("JumpSoundPlayer")
onready var dive_player = get_node("DiveSoundPlayer")
onready var fall_player = get_node("FallSoundPlayer")

func is_grounded():
	return test_move(self.transform, Vector2(0, 0.1)) and collided_last_frame
	
func is_ceiling():
	return test_move(self.transform, Vector2(0, -0.1)) and collided_last_frame
	
func is_walled():
	return (is_walled_left() or is_walled_right()) and collided_last_frame

func is_walled_left():
	return test_move(self.transform, Vector2(-0.1, 0)) and collided_last_frame

func is_walled_right():
	return test_move(self.transform, Vector2(0.1, 0)) and collided_last_frame

func hide():
	visible = false
	velocity = Vector2(0, 0)
	position = init_pos
	
func show():
	visible = true
	
func set_state(state, delta: float):
	var old_state = self.state
	last_state = old_state
	self.state = null
	if old_state != null:
		old_state._stop(delta);
	if state != null:
		self.state = state;
		state._start(delta);
	
func get_state_instance(name: String):
	return state_map[name]
	
func set_state_by_name(name: String, delta: float):
	set_state(state_map[name], delta)
	
func _ready():
	real_friction = friction
	for name in state_names:
		var state = load("res://assets/states/" + name + ".tres")
		state.character = self
		state.name = name
		states.append(state)
		state_map[name] = state
	
func _physics_process(delta: float):
	OS.set_window_title("Super Mario 127 (FPS: " + str(Engine.get_frames_per_second()) + ")")

	if global_vars_node.game_mode != "Editing":

		# Gravity
		velocity += global_vars_node.gravity * Vector2(gravity_scale, gravity_scale)

		# Collision Checks
		# Down
		if (test_move(self.transform, Vector2(0, 0.1))):
			collision_down = true
		else:
			collision_down = false
		# Up
		if (test_move(self.transform, Vector2(0, -0.1))):
			collision_up = true
		else:
			collision_up = false
		# Left
		if (test_move(self.transform, Vector2(-0.1, 0))):
			collision_left = true
		else:
			collision_left = false
		# Right
		if (test_move(self.transform, Vector2(0.1, 0))):
			collision_right = true
		else:
			collision_right = false

		# Movement
		move_direction = 0
		if (Input.is_action_pressed("move_left") && (state != get_state_instance("Slide") || !is_grounded()) and state != get_state_instance("Bonked")):
			move_direction = -1
		elif (Input.is_action_pressed("move_right") && (state != get_state_instance("Slide") || !is_grounded()) and state != get_state_instance("Bonked")):
			move_direction = 1
		if controllable:
			if move_direction != 0:
				if is_grounded():
					if ((velocity.x > 0 && move_direction == -1) || (velocity.x < 0 && move_direction == 1)):
						velocity.x += deceleration * move_direction
					elif ((velocity.x < move_speed && move_direction == 1) || (velocity.x > -move_speed && move_direction == -1)):
						velocity.x += acceleration * move_direction
					elif ((velocity.x > move_speed && move_direction == 1) || (velocity.x < -move_speed && move_direction == -1)):
						velocity.x -= 3.5 * move_direction
					facing_direction = move_direction

					if state != get_state_instance("Spinning"):
						if !test_move(transform, Vector2(velocity.x * delta, 0)):
							if move_direction == 1:
								sprite.animation = "movingRight"
							else:
								sprite.animation = "movingLeft"
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
					if ((velocity.x < move_speed && move_direction == 1) || (velocity.x > -move_speed && move_direction == -1)):
						velocity.x += air_accel * move_direction
					elif ((velocity.x > move_speed && move_direction == 1) || (velocity.x < -move_speed && move_direction == -1)):
						velocity.x -= 0.25 * move_direction
					if state != get_state_instance("Dive"):
						facing_direction = move_direction
			else:
				if (velocity.x > 0):
					if (velocity.x > 15):
						if (is_grounded()):
							velocity.x -= friction
						else:
							velocity.x -= air_fricc
					else:
						velocity.x = 0
				elif (velocity.x < 0):
					if (velocity.x < -15):
						if (is_grounded()):
							velocity.x += friction
						else:
							velocity.x += air_fricc
					else:
						velocity.x = 0
	
				if state != get_state_instance("Spinning"):
					if is_grounded():
						if facing_direction == 1:
							sprite.animation = "idleRight"
						else:
							sprite.animation = "idleLeft"
						sprite.speed_scale = 1
		else:
			if state != get_state_instance("Spinning"):
				sprite.animation = "idleRight"
		
		for state in states:
			state.handle_update(delta)

		# Move by velocity
		velocity = move_and_slide(velocity)
		var slide_count = get_slide_count()
		collided_last_frame = true if slide_count else false
		
		# Boundaries
		if position.y > (level_settings_node.level_size.y * 32) + 128:
			#fall_player.play()
			kill()
		if position.x < 0:
			position.x = 0
			velocity.x = 0
			if is_grounded() and move_direction != 0:
				if facing_direction == 1:
					sprite.animation = "idleRight"
				else:
					sprite.animation = "idleLeft"
		if position.x > level_settings_node.level_size.x * 32:
			position.x = level_settings_node.level_size.x * 32
			velocity.x = 0
			if is_grounded() and move_direction != 0:
				if facing_direction == 1:
					sprite.animation = "idleRight"
				else:
					sprite.animation = "idleLeft"
		last_velocity = velocity

func kill():
	var music = get_node("../Music")
	current_jump = 0
	velocity = Vector2(0, 0)
	controllable = true
	set_state_by_name("Fall", 0)
	var global_vars = get_node("../GlobalVars")
	global_vars.reload()
	music.stop()
	music.play()

func exit():
	var music = get_node("../Music")
	current_jump = 0
	velocity = Vector2(0, 0)
	controllable = true
	set_state_by_name("Fall", 0)
	music.stop()
	var mode_switcher = get_node("../ModeSwitcher")
	mode_switcher.switch_to_editing()
