extends State

class_name BackflipState

var is_crouch = false
var stop = false
var getup_buffer = 0
var ledge_buffer = 0
var direction_on_start = 1
var spins = 0
var unlock_timer = 0.0

export var backflip_power := Vector2(280, 360) # no longer nice

func _ready():
	priority = 4
	disable_animation = true
	override_rotation = true
	disable_turning = true

func _start(_delta):
	priority = 4
	unlock_timer = 0.4
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
	character.velocity.x /= 2
	character.velocity.x += backflip_power.x * -character.facing_direction
	character.velocity.y = -backflip_power.y
	character.position.x -= 2 * character.facing_direction
	character.position.y -= 3
	disable_turning = true
	sound_player.play_double_jump_sound()
	if character.facing_direction == -1:
		character.anim_player.play("backflip")
	else:
		character.anim_player.play("backflip_right")
	spins = 0

func _update(_delta):
	var sprite = character.animated_sprite
	if (character.facing_direction == 1):
		sprite.animation = "jumpRight"
	else:
		sprite.animation = "jumpLeft"
		
func _stop(_delta):
	character.anim_player.stop()
	
func _stop_check(_delta):
	# warning-ignore: unused_variable
	var sprite = character.animated_sprite
	return character.is_grounded()

func _general_update(delta):
	if unlock_timer > 0:
		unlock_timer -= delta
		if unlock_timer <= 0:
			unlock_timer = 0
			priority = 1
