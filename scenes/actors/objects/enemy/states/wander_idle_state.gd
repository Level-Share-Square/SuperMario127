class_name EnemyWanderIdleState
extends EnemyStopState


export var min_idle_time: int = 180
export var max_idle_time: int = 300

var time: int = 500


func _start() -> void:
	time = rand_range(min_idle_time, max_idle_time)


func _update(delta: float) -> void:
	._update(delta)
	
	time -= 1
	
	if time <= 0:
		enemy.set_state_by_name("WanderState")
