extends EnemyWanderIdleState


func _start() -> void:
	._start()
	
	enemy.sprite.play("idle")

func _update(_delta: float) -> void:
	._update(_delta)
	
	enemy.sprite.play("idle")
	
	if is_instance_valid(enemy.player_detector.get_player()):
		enemy.set_state_by_name("ChaseState")
