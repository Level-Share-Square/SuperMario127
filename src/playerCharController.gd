extends KinematicBody2D

class_name Character

export var init_pos = Vector2(0, 0)
export var velocity = Vector2(0, 0)
var last_velocity = Vector2(0, 0)
export var gravity_scale = 1
export var facing_direction = 1

export var move_speed = 216.0
export var acceleration = 7.5
export var deceleration = 25.0
export var air_accel = 7.5
export var friction = 10.5
export var air_fricc = 1.15
export var jump_power = 350.0
var jump_playing = true

export var divePower = Vector2(1350, 75)
var diving = false
export var canDive = true
var rotating = false
var sliding = false
var diveRecharge = 0
var oldFriction = 10.5
var gettingUp = false
export var getUpPower = 320.0
var lastAboveRotLimit = false
var canJump = true
var canMove = true

export var walljump_power = Vector2(350, 320)
var directionOnWJ = 1
var direction_on_stick = 1
var wallJumping = false
var wallJumpTimer = 0.0
var lastWallDirection = 1

var jumpBuffer = 0.0
var ledgeBuffer = 0.0
var wjBuffer = 0.0
var wallBuffer = 0.0

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


onready var global_vars_node = get_node("../GlobalVars")
onready var level_settings_node = get_node("../LevelSettings")
onready var collision_shape = get_node("CollisionShape2D")
onready var sprite = get_node("AnimatedSprite")
onready var jump_player = get_node("JumpSoundPlayer")
onready var dive_player = get_node("DiveSoundPlayer")
onready var fall_player = get_node("FallSoundPlayer")

func is_grounded():
	return test_move(self.transform, Vector2(0, 0.1))
	
func is_walled():
	return is_walled_left() or is_walled_right()

func is_walled_left():
	return test_move(self.transform, Vector2(-0.1, 0))

func is_walled_right():
	return test_move(self.transform, Vector2(0.1, 0))

func hide():
	visible = false
	velocity = Vector2(0, 0)
	position = init_pos
	
func show():
	visible = true
	
func set_state(state, delta: float):
	var old_state = self.state
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
	for name in state_names:
		var state = load("res://assets/states/" + name + ".tres")
		state.character = self
		state.name = name
		states.append(state)
		state_map[name] = state
	
func _physics_process(delta: float):

	OS.set_window_title("Super Mario 127 (FPS: " + str(Engine.get_frames_per_second()) + ")")

	if global_vars_node.game_mode != "Editing":

		# Buffers
		if jumpBuffer > 0:
			jumpBuffer -= delta
			if jumpBuffer < 0:
				jumpBuffer = 0
		if ledgeBuffer > 0:
			ledgeBuffer -= delta
			if ledgeBuffer < 0:
				ledgeBuffer = 0
		if wjBuffer > 0:
			wjBuffer -= delta
			if wjBuffer < 0:
				wjBuffer = 0
		if wallBuffer > 0:
			wallBuffer -= delta
			if wallBuffer < 0:
				wallBuffer = 0
		if wallJumpTimer > 0:
			wallJumpTimer -= delta
			if wallJumpTimer < 0:
				wallJumpTimer = 0

		# Gravity
		velocity += global_vars_node.gravity * Vector2(gravity_scale, gravity_scale)

		# Collision Checks
		# Down
		if (test_move(self.transform, Vector2(0, 0.1))):
			collision_down = true
			velocity.y = 0
			ledgeBuffer = 0.075
		# Up
		if (test_move(self.transform, Vector2(0, -0.1))):
			collision_up = true
			velocity.y = 10
		# Left
		if (test_move(self.transform, Vector2(-0.1, 0))):
			collision_left = true
			velocity.x = 0
		# Right
		if (test_move(self.transform, Vector2(0.1, 0))):
			collision_right = true
			velocity.x = 0

		# Movement
		var moveDirection = 0
		if (Input.is_action_pressed("move_left") && state != get_state_instance("Slide")):
			moveDirection = -1
		elif (Input.is_action_pressed("move_right") && state != get_state_instance("Slide")):
			moveDirection = 1
		if moveDirection != 0:
			if is_grounded():
				if ((velocity.x > 0 && moveDirection == -1) || (velocity.x < 0 && moveDirection == 1)):
					velocity.x += deceleration * moveDirection
				elif ((velocity.x < move_speed && moveDirection == 1) || (velocity.x > -move_speed && moveDirection == -1)):
					velocity.x += acceleration * moveDirection
				elif ((velocity.x > move_speed && moveDirection == 1) || (velocity.x < -move_speed && moveDirection == -1)):
					velocity.x -= 3.5 * moveDirection
				facing_direction = moveDirection

				if moveDirection == 1:
					sprite.animation = "movingRight"
				else:
					sprite.animation = "movingLeft"
				if (abs(velocity.x) > move_speed):
					sprite.speed_scale = abs(velocity.x) / move_speed
				else:
					sprite.speed_scale = 1
			else:
				if ((velocity.x < move_speed && moveDirection == 1) || (velocity.x > -move_speed && moveDirection == -1)):
					velocity.x += air_accel * moveDirection
				elif ((velocity.x > move_speed && moveDirection == 1) || (velocity.x < -move_speed && moveDirection == -1)):
					velocity.x -= 0.25 * moveDirection

				if (velocity.x > 0 && moveDirection == 1) or (velocity.x < 0 && moveDirection == -1):
					facing_direction = moveDirection
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

			if is_grounded():
				if facing_direction == 1:
					sprite.animation = "idleRight"
				else:
					sprite.animation = "idleLeft"
				sprite.speed_scale = 1

##		
#		# Jump
#		if Input.is_action_just_pressed("jump") && canJump:
#			jumpBuffer = 0.075
#		if jumpBuffer > 0 && ledgeBuffer > 0 && canJump:
#			velocity.y = -jump_power
#			position.y -= 3
#			ledgeBuffer = 0
#			jumpBuffer = 0
#			jump_playing = true
#			jump_player.play()
#			is_grounded() = false
#		if jump_playing && velocity.y < 0 && !is_grounded():
#			if facing_direction == 1:
#				sprite.animation = "jumpRight"
#			else:
#				sprite.animation = "jumpLeft"
#		else:
#			jump_playing = false
#			if !is_grounded():
#				if facing_direction == 1:
#					sprite.animation = "fallRight"
#				else:
#					sprite.animation = "fallLeft"
#
#		# Dive
#		if Input.is_action_pressed("dive") && !is_grounded() && !collision_left && !collision_right && canDive:
#			velocity.x = velocity.x - (velocity.x - (divePower.x * facing_direction)) / 5
#			velocity.y += divePower.y
#			canDive = false
#			diving = true
#			oldFriction = friction
#			rotating = true
#			canJump = false
#			dive_player.play()
#		if (diving):
#			if (is_grounded()):
#				friction = 2.25
#				diving = false
#				sliding = true
#				canMove = false
#				canJump = false
#				sprite.rotation_degrees = 0
#				velocity.y = 0
#			else:
#				friction = oldFriction
#			if (facing_direction == 1):
#				sprite.animation = "diveRight"
#			else:
#				sprite.animation = "diveLeft"
#		if (sliding):
#			if (facing_direction == 1):
#				sprite.animation = "diveRight"
#			else:
#				sprite.animation = "diveLeft"
#			if (velocity.x < 15 && velocity.x > -15):
#				sliding = false
#				rotating = false
#				friction = oldFriction
#				canDive = true
#				canJump = true
#				canMove = true
#				sprite.rotation_degrees = 0
#				if (facing_direction == 1):
#					sprite.animation = "idleRight"
#				else:
#					sprite.animation = "idleLeft"
#			elif (Input.is_action_pressed("jump")):
#				if (!gettingUp):
#					sliding = false
#					rotating = false
#					gettingUp = true
#					diveRecharge = 0.35
#					canJump = true
#					canMove = true
#					friction = oldFriction
#					velocity.y = -getUpPower
#					jump_player.play()
#					sprite.rotation_degrees = 0
#					if (facing_direction == 1):
#						sprite.animation = "jumpRight"
#					else:
#						sprite.animation = "jumpLeft"
#		if (diveRecharge > 0):
#			diveRecharge -= delta
#			if (diveRecharge <= 0):
#				diveRecharge = 0
#				gettingUp = false
#				canDive = true
#		if (rotating || sliding):
#			var newAngle = ((velocity.y / 7) * facing_direction) + (90 * facing_direction)
#			if (velocity.y < global_vars_node.maxGravityVelocity.y):
#				sprite.rotation_degrees = newAngle
#				lastAboveRotLimit = false
#			else:
#				if (!lastAboveRotLimit):
#					sprite.rotation_degrees = ((global_vars_node.maxGravityVelocity.y / 7) * facing_direction) + (90 * facing_direction)
#				sprite.rotation_degrees += 0.1
#				lastAboveRotLimit = true
#
#		# Wall Jump
#		if Input.is_action_just_pressed("jump") && !is_grounded():
#			wjBuffer = 0.075
#		if (collision_left || collision_right):
#			wallBuffer = 0.1
#			lastWallDirection = 1
#			wallJumping = false
#			if collision_right:
#				lastWallDirection = -1
#		if !is_grounded() && wallBuffer > 0 && wjBuffer > 0 && !jump_playing && !diving:
#			facing_direction = 1
#			if lastWallDirection == -1:
#				facing_direction = -1
#			velocity.x = walljump_power.x * facing_direction
#			velocity.y = -walljump_power.y
#			self.position.x -= 2
#			self.position.y -= 2
#			collision_left = false
#			collision_right = false
#			is_grounded() = false
#			directionOnWJ = facing_direction
#			wallJumping = true
#			wallBuffer = 0
#			wjBuffer = 0
#			wallJumpTimer = 0.45
#			jump_player.play()
#		if diving:
#			wallJumping = false
#		if wallJumping:
#			if (directionOnWJ == 1):
#				sprite.animation = "jumpRight"
#			else:
#				sprite.animation = "jumpLeft"
#			if (is_grounded()):
#				wallJumping = false
#		elif (collision_left || collision_right) && !diving && !is_grounded():
#			if (collision_right):
#				sprite.animation = "wallSlideRight"
#			else:
#				sprite.animation = "wallSlideLeft"
		
		for state in states:
			state.handleUpdate(delta)

		# Move by velocity
		move_and_slide(velocity)

		# Boundaries
		if position.y > (level_settings_node.level_size.y * 32) + 128:
			#fall_player.play()
			kill()
		if position.x < 0:
			position.x = 0
			velocity.x = 0
		if position.x > level_settings_node.level_size.x * 32:
			position.x = level_settings_node.level_size.x * 32
			velocity.x = 0
		last_velocity = velocity

func kill():
	var modeSwitcher = get_node("../ModeSwitcher")
	modeSwitcher.switchToEditing()
