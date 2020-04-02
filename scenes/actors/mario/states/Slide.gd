extends State

class_name SlideState

onready var dive_player = character.get_node("JumpSoundPlayer")

var stop = false
var getup_buffer = 0

func _ready():
	priority = 4
	disable_movement = true
	disable_animation = true
	disable_snap = false
	override_rotation = true

func _start(delta):
	if character.state != character.get_state_node("Jump"):
		var sprite = character.animated_sprite
		character.friction = 4
	
func _update(delta):
	var sprite = character.animated_sprite
	if (character.facing_direction == 1):
		sprite.animation = "diveRight"
	else:
		sprite.animation = "diveLeft"
		
	var ground_check = character.get_node("GroundCheck")
	var sprite_rotation = 90
	
	if character.is_grounded():
		var normal = character.ground_check.get_collision_normal()
		sprite_rotation = atan2(normal.y, normal.x) + (PI/2)
		sprite_rotation += PI/2 * character.facing_direction
		
	sprite.rotation = lerp(sprite.rotation, sprite_rotation, delta * character.rotation_interpolation_speed)
		
	if getup_buffer > 0:
		stop = true

func _stop(delta):
	var collision = character.get_node("Collision")
	var dive_collision = character.get_node("CollisionDive")
	var ground_collision = character.get_node("GroundCollision")
	var dive_ground_collision = character.get_node("GroundCollisionDive")
	var sprite = character.animated_sprite
	character.friction = character.real_friction
	if !character.is_grounded():
		character.set_state_by_name("DiveState", delta)
		character.position.y -= 5
	elif getup_buffer > 0 or abs(character.velocity.x) < 5:
		character.set_state_by_name("GetupState", delta)
		if !character.test_move(character.transform, Vector2(0, -16)):
			character.position.y -= 16
		collision.disabled = false
		ground_collision.disabled = false
		dive_collision.disabled = true
		dive_ground_collision.disabled = true
		character.attacking = false
	else:
		sprite.rotation_degrees = 0
		collision.disabled = false
		ground_collision.disabled = false
		dive_collision.disabled = true
		dive_ground_collision.disabled = true
	stop = false

func _stop_check(delta):
	return abs(character.velocity.x) < 5 or stop or !character.is_grounded()

func _general_update(delta):
	if character.jump_just_pressed:
		getup_buffer = 0.075
	if getup_buffer > 0:
		getup_buffer -= delta
		if getup_buffer < 0:
			getup_buffer = 0
