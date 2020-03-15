extends State

class_name JumpState

export var jump_power: float = 350
export var double_jump_power: float = 425
export var triple_jump_power: float = 495
var ground_buffer = 0
var jump_buffer = 0
var ledge_buffer = 0
var jump_playing = false
var last_grounded = false
var rotating = false
var direction_on_tj = 1

func _ready():
	priority = 1

func lerp(a, b, t):
	return (1 - t) * a + t * b

func _start_check(delta):
	return ledge_buffer > 0 and jump_buffer > 0

func _start(delta):
	var sprite = character.animated_sprite
	jump_buffer = 0
	ground_buffer = 0
	jump_playing = true
	if character.current_jump == 2 and abs(character.velocity.x) < 80:
		character.current_jump = 1
	if character.current_jump != 2 && character.last_state == character.get_state_node("Spinning"):
		character.set_state_by_name("Spinning", delta)
	if character.current_jump == 0:
		var jump_player = character.get_node("jump_sounds")
		jump_player.play()
		character.velocity.y = -jump_power
		character.position.y -= 3
		character.jump_animation = 0
		character.current_jump = 1
	elif character.current_jump == 1:
		var jump_player = character.get_node("dble_jump_sounds")
		jump_player.play()
		character.velocity.y = -double_jump_power
		character.position.y -= 3
		character.jump_animation = 1
		character.current_jump = 2
	elif character.current_jump == 2:
		var jump_player = character.get_node("trple_jump_sounds")
		jump_player.play()
		character.velocity.y = -triple_jump_power
		character.position.y -= 3
		character.jump_animation = 2
		character.current_jump = 0
		direction_on_tj = character.facing_direction
		sprite.rotation_degrees = direction_on_tj

func _update(delta):
	var sprite = character.animated_sprite
	if jump_playing && character.velocity.y < 0 && !character.is_grounded():
		if character.facing_direction == 1:
			if character.jump_animation == 0:
				sprite.animation = "jumpRight"
			elif character.jump_animation == 1:
				sprite.animation = "doubleJumpRight"
			else:
				if direction_on_tj == 1:
					sprite.animation = "tripleJumpRight"
				else:
					sprite.animation = "tripleJumpLeft"
				rotating = true
		else:
			if character.jump_animation == 0:
				sprite.animation = "jumpLeft"
			elif character.jump_animation == 1:
				sprite.animation = "doubleJumpLeft"
			else:
				if direction_on_tj == 1:
					sprite.animation = "tripleJumpRight"
				else:
					sprite.animation = "tripleJumpLeft"
				rotating = true
	else:
		jump_playing = false

func _stop_check(delta):
	return character.is_grounded() or character.velocity.y > 0

func _general_update(delta):
	var sprite = character.animated_sprite
	if rotating:
		if character.velocity.y > 0:
			character.jump_animation = 0
		if character.state == character.get_state_node("Dive"):
			rotating = false
			character.jump_animation = 0
		if character.is_grounded() or abs(sprite.rotation_degrees) > 360 or character.state == character.get_state_node("WallSlide") or character.controllable == false:
			rotating = false
			sprite.rotation_degrees = 0
			character.jump_animation = 0
		else:
			sprite.rotation_degrees = lerp(abs(sprite.rotation_degrees), 380, 4 * delta) * direction_on_tj
	if character.is_grounded() and !last_grounded:
		ground_buffer = 0.20
	elif character.is_grounded():
		ledge_buffer = 0.125
	if ground_buffer > 0:
		ground_buffer -= delta
		if ground_buffer < 0:
			ground_buffer = 0
			character.current_jump = 0
	if ledge_buffer > 0 && !character.is_grounded():
		ledge_buffer -= delta
		if ledge_buffer < 0:
			ledge_buffer = 0	
	if jump_buffer > 0:
		jump_buffer -= delta
		if jump_buffer < 0:
			jump_buffer = 0
	if Input.is_action_just_pressed("jump"):
		jump_buffer = 0.075
	last_grounded = character.is_grounded()
