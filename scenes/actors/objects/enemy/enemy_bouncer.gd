extends Area2D


onready var enemy: EnemyBase = get_owner()
onready var initial_layer: int = collision_layer
onready var initial_mask: int = collision_mask

export var bounce_velocity := Vector2(50, -50)
export var blacklisted_states: PoolStringArray

signal bounced


func state_changed(new_state: EnemyState) -> void:
	if new_state.name in blacklisted_states:
		collision_layer = 0
		collision_mask = 0
	else:
		collision_layer = initial_layer
		collision_mask = initial_mask


func area_entered(colliding_area: Area2D) -> void:
	if colliding_area.owner == enemy: return
	
	var bounce_dir: int = sign(global_position.x - colliding_area.global_position.x)
	var x_vel: float = bounce_velocity.x * bounce_dir
	if is_instance_valid(colliding_area.owner) and colliding_area.owner is EnemyBase:
		if abs(colliding_area.owner.velocity.x) > abs(enemy.velocity.x):
			x_vel += colliding_area.owner.velocity.x
		else:
			x_vel += enemy.velocity.x
	enemy.set_deferred("velocity", Vector2(x_vel, bounce_velocity.y))
	emit_signal("bounced")


func check_collisions() -> void:
	for area in get_overlapping_areas():
		area_entered(area)
