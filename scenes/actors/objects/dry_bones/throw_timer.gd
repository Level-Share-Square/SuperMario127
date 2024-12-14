extends Timer


func state_changed(new_state: EnemyState):
	if new_state.name == "IdleState" or new_state.name == "PatrolState":
		start()
	else:
		stop()
