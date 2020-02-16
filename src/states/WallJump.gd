extends State

class_name WallJumpState

export var wallJumpPower = Vector2(350, 320)

var press_buffer = 0.0
var wall_jump_timer = 0.0
var direction_on_wj = 1

func _startCheck(delta):
	return character.state == character.getStateInstance("WallSlide") and press_buffer > 0

func _start(delta):
	var jumpPlayer = character.get_node("JumpSoundPlayer")
	press_buffer = 0
	character.facingDirection = -character.direction_on_stick
	character.velocity.x = wallJumpPower.x * character.facingDirection
	character.velocity.y = -wallJumpPower.y
	character.position.x -= 2
	character.position.y -= 2
	direction_on_wj = character.facingDirection
	wall_jump_timer = 0.45
	jumpPlayer.play()
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

func _stopCheck(delta):
	return wall_jump_timer <= 0 or character.isWalled() or character.isGrounded()
	
func _generalUpdate(delta):
	if Input.is_action_just_pressed("jump") && !character.isGrounded():
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
