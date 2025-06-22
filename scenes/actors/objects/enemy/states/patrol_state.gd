class_name EnemyPatrolState
extends EnemyState

# Signals if terrain is present ahead of the enemy.
onready var ledge_detector: RayCast2D = get_node_or_null("Ledge")

# Signals if a wall is in the facing direction of an enemy.
onready var wall_detector: RayCast2D = get_node_or_null("Wall")

# Signals if the enemy is inside another enemy (will disable wall checks with enemies temporarily).
onready var enemy_detector: Area2D = get_node_or_null("Enemy")

export var move_speed: float = 30
export var accel: float = 2
export var ledge_turning: bool

var was_grounded: bool


func _ready():
	if is_instance_valid(ledge_detector):
		ledge_detector.add_exception(enemy)
	if is_instance_valid(wall_detector):
		wall_detector.add_exception(enemy)


func enable_raycasts(is_enabled: bool) -> void:
	if ledge_turning and is_instance_valid(ledge_detector):
		ledge_detector.set_deferred("enabled", is_enabled)
	else:
		ledge_detector.set_deferred("enabled", false)
	wall_detector.set_deferred("enabled", is_enabled)


func _start() -> void:
	enemy.sprite.play("walk")
	enable_raycasts(true)


func _stop() -> void:
	enable_raycasts(false)


func _update(delta: float) -> void:
	if ledge_turning:
		if was_grounded and not ledge_detector.is_colliding():
			enemy.facing_direction = -enemy.facing_direction
		ledge_detector.position.x = abs(ledge_detector.position.x) * enemy.facing_direction
	
	# i tried,,, but is_on_wall() simply wont work no matter what i do
	if wall_detector.is_colliding():
		enemy.facing_direction = -enemy.facing_direction
		enemy.velocity.x = enemy.facing_direction
	wall_detector.cast_to.x = abs(wall_detector.cast_to.x) * enemy.facing_direction
	
	if is_instance_valid(enemy_detector) and enemy_detector.get_overlapping_areas().size():
		wall_detector.set_collision_mask_bit(2, false)
	else:
		wall_detector.set_collision_mask_bit(2, true)
	
	enemy.velocity.x = move_toward(enemy.velocity.x,
		move_speed * enemy.facing_direction, delta * accel * 60)
	
	# otherwise they turn when the floor disappears
	was_grounded = enemy.is_on_floor()
