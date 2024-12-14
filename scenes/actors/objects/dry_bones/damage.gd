extends EnemyDamage


func hurt() -> void:
	enemy.set_state_by_name("CrumbleState")


func strong_hurt() -> void:
	enemy.set_state_by_name("DieState")


func spin_attacked() -> void:
	if is_instance_valid(enemy.state):
		if enemy.state.name == "CrumbleState" or enemy.state.name == "DieState":
			return
	enemy.set_state_by_name("StunnedState")


func ground_pound() -> void:
	hurt()


func incinerated() -> void:
	pass

