class_name EnemyWanderState
extends EnemyPatrolState

export var min_wander_time: int = 180
export var max_wander_time: int = 300

var time: int = 500


func _start() -> void:
	._start()
	
	enemy.facing_direction = round(rand_range(0, 1)) * 2 - 1
	time = rand_range(min_wander_time, max_wander_time)


func _update(delta: float) -> void:
	._update(delta)
	
	time -= 1
	
	if time <= 0:
		enemy.set_state_by_name("IdleState")
