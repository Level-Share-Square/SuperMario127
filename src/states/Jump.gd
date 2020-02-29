extends State

class_name JumpState

export var jump_power: float = 350
export var double_jump_power: float = 425
export var triple_jump_power: float = 495
var ground_buffer = 0
var jump_buffer = 0
var jump_playing = false
var last_grounded = false
var rotating = false
var direction_on_tj = 1

func _start_check(delta):
	return character.is_grounded() and jump_buffer > 0 and character.state != character.get_state_instance("Slide")

func _start(delta):
	var sprite = character.get_node("AnimatedSprite")
	jump_buffer = 0
	ground_buffer = 0
	jump_playing = true
	if character.current_jump == 2 and abs(character.velocity.x) < 5:
		character.current_jump = 1
	if character.current_jump == 0:
		var jump_player = character.get_node("JumpSoundPlayer")
		jump_player.play()
		character.velocity.y = -jump_power
		character.position.y -= 3
		character.jump_animation = 0
		character.current_jump = 1
	elif character.current_jump == 1:
		var jump_player = character.get_node("DoubleJumpSoundPlayer")
		jump_player.play()
		character.velocity.y = -double_jump_power
		character.position.y -= 3
		character.jump_animation = 1
		character.current_jump = 2
	elif character.current_jump == 2:
		var jump_player = character.get_node("TripleJumpSoundPlayer")
		jump_player.play()
		character.velocity.y = -triple_jump_power
		character.position.y -= 3
		character.jump_animation = 2
		character.current_jump = 0
		direction_on_tj = character.facing_direction
		sprite.rotation_degrees = direction_on_tj

func _update(delta):
	var sprite = character.get_node("AnimatedSprite")
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
	if character.is_ceiling():
		character.velocity.y = 3
		
func _stop(delta):
	pass

func _stop_check(delta):
	return character.is_grounded()

func _general_update(delta):
	var sprite = character.get_node("AnimatedSprite")
	if rotating:
		if character.state == character.get_state_instance("Dive"):
			rotating = false
			character.jump_animation = 0
		if character.is_grounded() or abs(sprite.rotation_degrees) > 360 or character.state == character.get_state_instance("WallSlide"):
			rotating = false
			sprite.rotation_degrees = 0
			character.jump_animation = 0
		else:
			sprite.rotation_degrees += 4 * direction_on_tj
			character.facing_direction = direction_on_tj
	if character.is_grounded() and !last_grounded:
		ground_buffer = 0.1
	if ground_buffer > 0:
		ground_buffer -= delta
		if ground_buffer < 0:
			ground_buffer = 0
			character.current_jump = 0
	if jump_buffer > 0:
		jump_buffer -= delta
		if jump_buffer < 0:
			jump_buffer = 0
	if Input.is_action_just_pressed("jump"):
		jump_buffer = 0.075
	last_grounded = character.is_grounded()
