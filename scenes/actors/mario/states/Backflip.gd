extends State

class_name BackflipState

var is_crouch = false
var stop = false
var getup_buffer = 0
var ledge_buffer = 0
var direction_on_start = 1

export var backflip_power := Vector2(180, 420) #nice

func _ready():
	priority = 4
	disable_animation = true
	override_rotation = true
	disable_turning = true

func _start(delta):
	direction_on_start = character.facing_direction
	var sound_player = character.get_node("Sounds")
	var collision = character.get_node("Collision")
	var dive_collision = character.get_node("CollisionDive")
	var ground_collision = character.get_node("GroundCollision")
	var left_collision = character.get_node("LeftCollision")
	var right_collision = character.get_node("RightCollision")
	var dive_ground_collision = character.get_node("GroundCollisionDive")
	collision.disabled = false
	ground_collision.disabled = false
	left_collision.disabled = false
	right_collision.disabled = false
	dive_collision.disabled = true
	dive_ground_collision.disabled = true
	character.velocity.x = backflip_power.x * -character.facing_direction
	character.velocity.y = -backflip_power.y
	character.position.x -= 2 * character.facing_direction
	character.position.y -= 3
	disable_turning = true
	sound_player.play_double_jump_sound()

func _update(delta):
	var sprite = character.animated_sprite
	if character.velocity.y <= 0 and disable_turning:
		priority = 4
		if (character.facing_direction == 1):
			sprite.animation = "tripleJumpRight"
		else:
			sprite.animation = "tripleJumpLeft"
	else:
		disable_turning = false
		priority = 0
		if (character.facing_direction == 1):
			sprite.animation = "fallRight"
		else:
			sprite.animation = "fallLeft"
	
	sprite.rotation_degrees = lerp(abs(sprite.rotation_degrees), 370, 4 * delta) * direction_on_start
		
func _stop(_delta):
	var sprite = character.animated_sprite
	sprite.rotation_degrees = 0
	
func _stop_check(_delta):
	var sprite = character.animated_sprite
	return character.is_grounded()
