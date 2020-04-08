extends State

class_name BonkedState

export var bonk_direction: int = 1
var frames_bonked = 0

func _ready():
	priority = 5
	disable_turning = true
	disable_movement = true
	frames_bonked = 0

func _start_check(_delta):
	return false
	
func _start(_delta):
	bonk_direction = character.facing_direction
	character.current_jump = 0

func _update(delta):
	var sprite = character.animated_sprite
	frames_bonked += 1
	if (bonk_direction == 1):
		sprite.animation = "bonkedRight"
	else:
		sprite.animation = "bonkedLeft"
	sprite.rotation_degrees = lerp(abs(sprite.rotation_degrees), 90, 0.75 * delta) * -character.facing_direction
	
func _stop(_delta):
	var sprite = character.animated_sprite
	sprite.rotation_degrees = 0
	frames_bonked = 0

func _stop_check(_delta):
	return character.is_grounded()
