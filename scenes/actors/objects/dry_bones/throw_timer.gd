extends Timer


onready var enemy: EnemyBase = get_owner()


func state_changed(new_state: EnemyState):
	wait_time = enemy.toss_time
	if new_state.name == "IdleState" or new_state.name == "PatrolState":
		start()
	else:
		stop()
