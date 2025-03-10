extends GameObject


enum ThwompState {Idle, Falling, Grounded, Rising}

onready var timer: Timer = $Timer
onready var body: KinematicBody2D = $Body
onready var crusher: KinematicBody2D = $Crusher
onready var sprite: AnimatedSprite = $Body/AnimatedSprite
onready var urgh_sound: AudioStreamPlayer2D = $Body/URGH
onready var crash_sound: AudioStreamPlayer2D = $Body/Crash

export var fall_accel: float = 1
export var fall_speed: float = 7

export var rise_accel: float = 0.1
export var rise_speed: float = 3

export var detection_range: float = 30
export var ground_pause_time: float = 0.5

var characters: Array
var velocity: Vector2
var motion: Vector2
var state: int = ThwompState.Idle

var initial_pos: Vector2
var collision_info: KinematicCollision2D
var fall_direction: Vector2 = Vector2(0, -1)


func _ready():
	if not enabled or mode == 1:
		body.collision_layer = 0
		body.collision_mask = 0
	else:
		initial_pos = global_position
		detection_range *= scale.x
		
		body.add_collision_exception_with(crusher)
		characters = get_tree().get_current_scene().get_characters()
		timer.wait_time = ground_pause_time


func set_state(new_state: int):
	state = new_state
	
	match new_state:
		ThwompState.Idle:
			sprite.play("idle")
		ThwompState.Falling:
			sprite.speed_scale = fall_accel
			sprite.play("urgh")
		ThwompState.Grounded:
			timer.start()
			urgh_sound.play()
			crash_sound.play()
		ThwompState.Rising:
			sprite.play("urgh", true)
			# just to prevent infinite loops :D
			collision_info = null
			global_position += Vector2(0, -1).rotated(global_rotation)


func _physics_process(delta):
	if not enabled or mode == 1: return
	
	var rotated_pos: Vector2 = rotated_origin(body.global_position, global_position, -global_rotation)
	var is_colliding: bool = is_instance_valid(collision_info)
	if is_colliding:
		velocity = Vector2.ZERO
	
	match state:
		ThwompState.Idle:
			#print("========IDLE=========")
			#print(velocity)
			velocity.y = 0
			#print(velocity)
			#print("=====================")
			var chars_rotated: Array = get_rotated_char_positions()
			for char_pos in chars_rotated:
				if (
					sign(char_pos.y - global_position.y) > 0 and
					abs(char_pos.x - global_position.x) < detection_range
				):
					set_state(ThwompState.Falling)
		
		ThwompState.Falling:
			#print("=======FALLING=======")
			#print(velocity)
			velocity.y = min(velocity.y + fall_accel, fall_speed)
			#print(velocity)
			#print("=====================")
			if is_colliding:
				set_state(ThwompState.Grounded)
		
		ThwompState.Grounded:
			#print("======GROUNDED=======")
			#print(velocity)
			velocity.y = 0
			#print(velocity)
			#print("=====================")
		
		ThwompState.Rising:
			#print("=======RISING========")
			#print(velocity)
			velocity.y = max(velocity.y - rise_accel, -rise_speed)
			#print(velocity)
			#print("=====================")
			if is_colliding or rotated_pos.y + velocity.y <= initial_pos.y:
				velocity = Vector2.ZERO
				body.global_position = initial_pos
				set_state(ThwompState.Idle)
	
	motion = velocity.rotated(global_rotation)
	collision_info = body.move_and_collide(motion)

	#var crush_info: KinematicCollision2D = crusher.move_and_collide(motion, true, true, true) # test only
	#if crush_info:
		#if crush_info.collider.has_method("try_move"):
			#crush_info.collider.try_move(crush_info.travel, self, delta)
			#distance_on_collision = body.global_position.distance_to()
			#collision_info = body.move_and_collide(collision_info.remainder)
	
	crusher.global_position = body.global_position
		
	#print(velocity, " ", motion)

func rotated_origin(point: Vector2, origin: Vector2, angle: float) -> Vector2:
	return origin + (point - origin).rotated(angle)


func get_rotated_char_positions() -> Array:
	var chars_rotated: Array = []
	for character in characters:
		chars_rotated.append(
			rotated_origin(character.global_position, global_position, -global_rotation))
	return chars_rotated
