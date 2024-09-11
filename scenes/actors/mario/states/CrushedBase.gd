class_name CrushedBaseState
extends State

const DIVE_CORRECT_OFFSET: int = 24
const MIN_SPRITE_SCALE: float = 0.1

const HURT_AMOUNT: int = 3
const HURT_INTERVAL: float = 3.0
const HURT_GRACE_PERIOD: float = 0.1

var damage_timer: float = 0

func _ready():
	priority = 8
	disable_turning = true
	disable_movement = true
	disable_knockback = true
	override_rotation = true

func _is_squished() -> bool:
	return false

func _past_squish_threshold() -> bool:
	return false

func get_ray_point(raycast: RayCast2D) -> Vector2:
	return raycast.get_collision_point() - raycast.global_position


func _start_check(_delta):
	return _is_squished()

func _start(_delta):
	character.velocity = Vector2.ZERO
	if character.using_dive_collision:
		character.set_dive_collision(false)
		character.position.y -= DIVE_CORRECT_OFFSET
	
	damage_timer = HURT_GRACE_PERIOD

func _update(delta):
	# if a moving block squishes him, he shouldn't move with the block
	character.velocity = Vector2.ZERO

	var sprite = character.sprite
	sprite.animation = "idleRight" if character.facing_direction == 1 else "idleLeft"
	sprite.rotation = 0
	
	if _past_squish_threshold():
		damage_timer -= delta
		if damage_timer <= 0:
			damage_timer = HURT_INTERVAL
			character.damage(HURT_AMOUNT, "crushed", 0)

func _stop(_delta):
	var sprite = character.sprite
	sprite.scale = Vector2.ONE
	sprite.offset = Vector2.ZERO

func _stop_check(_delta):
	return not _is_squished()
