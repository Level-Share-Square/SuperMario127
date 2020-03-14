extends KinematicBody2D

class_name Character

onready var states_node = $States
onready var animated_sprite = $AnimatedSprite

# Basic Physics
export var initial_position = Vector2(0, 0)
export var velocity = Vector2(0, 0)
var last_velocity = Vector2(0, 0)

export var gravity_scale = 1
export var facing_direction = 1
export var move_direction = 0

export var move_speed = 216.0
export var acceleration = 7.5
export var deceleration = 15.0
export var aerial_acceleration = 7.5
export var friction = 10.5
export var aerial_friction = 1.15

# Extra

export var disable_movement = false
export var disable_turning = false
export var disable_animation = false

# States
var state = null
var last_state = null
var controllable = true

# Collision vars
var collision_down
var collision_up
var collision_left
var collision_right
var collided_last_frame = false

#onready var global_vars_node = get_node("../GlobalVars")
#onready var level_settings_node = get_node("../LevelSettings")
onready var collision_shape = get_node("collision")
onready var sprite = get_node("sprite")

const temp_level_size = Vector2(80, 30)

func load_in(level_data : LevelData, level_area : LevelArea):
	pass

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
	position = initial_position

func show():
	visible = true

func set_state(state, delta: float):
	if state.priority > (self.state.priority or -1):
		var old_state = self.state
		last_state = old_state
		self.state = null
		if old_state != null:
			old_state._stop(delta);
		if state != null:
			self.state = state;
			state._start(delta);

func get_state_node(name: String):
	if states_node.has_node(name):
		return states_node.get_node(name)

func set_state_by_name(name: String, delta: float):
	set_state(get_state_node(name), delta)

func _ready():
	pass

func _physics_process(delta: float):
	OS.set_window_title("Super Mario 127 (FPS: " + str(Engine.get_frames_per_second()) + ")")

	var gravity = 7.82 #global_vars_node.gravity
	# Gravity
	velocity += gravity * Vector2(0, gravity_scale)
	
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
	if Input.is_action_pressed("move_left") and disable_movement == false:
		move_direction = -1
	elif Input.is_action_pressed("move_right") and disable_movement == false:
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

				if !disable_animation:
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
					velocity.x += aerial_acceleration * move_direction
				elif ((velocity.x > move_speed && move_direction == 1) || (velocity.x < -move_speed && move_direction == -1)):
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

			if !disable_animation:
				if is_grounded():
					if facing_direction == 1:
						sprite.animation = "idleRight"
					else:
						sprite.animation = "idleLeft"
					sprite.speed_scale = 1
	else:
		if !disable_animation:
			sprite.animation = "idleRight"

	for state_node in states_node.get_children():
		state_node.handle_update(delta)

	# Move by velocity
	velocity = move_and_slide(velocity)
	var slide_count = get_slide_count()
	collided_last_frame = true if slide_count else false

	# Boundaries
	if position.y > (temp_level_size.y * 32) + 128:
		#fall_player.play()
		kill()
	if position.x < 0:
		position.x = 0
		velocity.x = 0
		if is_grounded() and move_direction != 0 and !disable_animation:
			if facing_direction == 1:
				sprite.animation = "idleRight"
			else:
				sprite.animation = "idleLeft"
	if position.x > temp_level_size.x * 32:
		position.x = temp_level_size.x * 32
		velocity.x = 0
		if is_grounded() and move_direction != 0 and !disable_animation:
			if facing_direction == 1:
				sprite.animation = "idleRight"
			else:
				sprite.animation = "idleLeft"
	last_velocity = velocity

func kill():
	pass
	#var global_vars = get_node("../GlobalVars")
	#global_vars.reload()

func exit():
	pass
	#var mode_switcher = get_node("../ModeSwitcher")
	#mode_switcher.switch_to_editing()
