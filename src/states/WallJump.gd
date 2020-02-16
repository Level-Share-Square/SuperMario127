extends State

class_name WallJumpState

export var walljump_power = Vector2(350, 320)

var press_buffer = 0.0
var wall_jump_timer = 0.0
var direction_on_wj = 1

func _start_check(delta):
	return character.state == character.get_state_instance("WallSlide") and press_buffer > 0

func _start(delta):
	var jump_player = character.get_node("JumpSoundPlayer")
	press_buffer = 0
	character.facing_direction = -character.direction_on_stick
	character.velocity.x = walljump_power.x * character.facing_direction
	character.velocity.y = -walljump_power.y
	character.position.x -= 2
	character.position.y -= 2
	direction_on_wj = character.facing_direction
	wall_jump_timer = 0.45
	jump_player.play()
	pass

func _update(delta):
	var sprite = character.get_node("AnimatedSprite")
	if (direction_on_wj == 1):
		sprite.animation = "jumpRight"
	else:
		sprite.animation = "jumpLeft"
	pass

func _stop(delta):
	pass

func _stop_check(delta):
	return wall_jump_timer <= 0 or character.is_walled() or character.is_grounded()
	
func _generalUpdate(delta):
	if Input.is_action_just_pressed("jump") && !character.is_grounded():
		press_buffer = 0.075
	if press_buffer > 0:
		press_buffer -= delta
		if press_buffer <= 0:
			press_buffer = 0
	if wall_jump_timer > 0:
		wall_jump_timer -= delta
		if wall_jump_timer <= 0:
			wall_jump_timer = 0
	pass
