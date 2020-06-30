extends State

class_name BonkedState

export var bonk_direction: int = 1
var frames_bonked = 0
var bounces_left = 0

func _ready():
	priority = 4
	disable_turning = true
	disable_movement = true
	override_rotation = true
	frames_bonked = 0

func _start_check(_delta):
	return false
	
func _start(_delta):
	bonk_direction = character.facing_direction
	character.sprite.rotation_degrees = 0
	character.current_jump = 0
	character.friction = 4
	bounces_left = 2

func _update(delta):
	var sprite = character.animated_sprite
	frames_bonked += 1
	if (bonk_direction == 1):
		sprite.animation = "bonkedRight"
	else:
		sprite.animation = "bonkedLeft"
	var lerp_speed = 0.75
	var target_rotation = 90
	if character.is_grounded() and bounces_left > 0:
		bounces_left -= 1
		character.velocity.y = -50 * bounces_left
	if bounces_left < 2:
		target_rotation = 0
	sprite.rotation_degrees = lerp(abs(sprite.rotation_degrees), target_rotation, lerp_speed * delta) * -character.facing_direction
	
func _stop(_delta):
	var sprite = character.animated_sprite
	frames_bonked = 0
	sprite.offset.y = 0
	character.friction = character.real_friction

func _stop_check(_delta):
	return abs(character.velocity.x) < 10 and character.is_grounded()
