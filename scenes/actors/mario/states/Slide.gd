extends State

class_name SlideState

var stop = false
var getup_buffer = 0
var ledge_buffer = 0

func _ready():
	priority = 4
	disable_movement = true
	disable_animation = true
	disable_snap = false
	override_rotation = true

func _start(_delta):
	if character.state != character.get_state_node("Jump"):
		character.friction = 4
	
func _update(delta):
	var sprite = character.animated_sprite
	if (character.facing_direction == 1):
		sprite.animation = "diveRight"
	else:
		sprite.animation = "diveLeft"
		
	if character.is_grounded():
		var normal = character.ground_check.get_collision_normal()
		var sprite_rotation = atan2(normal.y, normal.x) + (PI/2)
		sprite_rotation += PI/2 * character.facing_direction
		
		sprite.rotation = lerp(sprite.rotation, sprite_rotation, delta * character.rotation_interpolation_speed)
		
func _stop(delta):
	character.friction = character.real_friction
	if character.is_grounded() and getup_buffer <= 0:
		change_to_getup(delta)
	else:
		character.position.y -= 5
		character.set_state_by_name("DiveState", delta)
	stop = false
	
func change_to_getup(delta):
	var collision = character.get_node("Collision")
	var dive_collision = character.get_node("CollisionDive")
	var ground_collision = character.get_node("GroundCollision")
	var left_collision = character.get_node("LeftCollision")
	var right_collision = character.get_node("RightCollision")
	var dive_ground_collision = character.get_node("GroundCollisionDive")
	character.set_state_by_name("GetupState", delta)
	if !character.test_move(character.transform, Vector2(0, -16)):
		character.position.y -= 16
	collision.disabled = false
	ground_collision.disabled = false
	left_collision.disabled = false
	right_collision.disabled = false
	dive_collision.disabled = true
	dive_ground_collision.disabled = true
	character.attacking = false
	getup_buffer = 0
	ledge_buffer = 0

func _stop_check(_delta):
	return (abs(character.velocity.x) < 5 and !character.inputs[8][0]) or stop or !character.is_grounded()

func _general_update(delta):
	if character.inputs[2][1]:
		getup_buffer = 0.075
	if getup_buffer > 0:
		getup_buffer -= delta
		if getup_buffer < 0:
			getup_buffer = 0
			
	if character.is_grounded() and character.state == self:
		ledge_buffer = 0.125
		
	if ledge_buffer > 0:
		if getup_buffer > 0:
			change_to_getup(delta)
			
		ledge_buffer -= delta
		if ledge_buffer < 0:
			ledge_buffer = 0
