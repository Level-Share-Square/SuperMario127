extends Timer


onready var enemy: EnemyBase = get_owner()


func state_changed(new_state: EnemyState):
	wait_time = enemy.regenerate_time
	if new_state.name == "CrumbleState":
		start()
	else:
		stop()
