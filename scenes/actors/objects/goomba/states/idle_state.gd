extends EnemyWanderIdleState


func _start() -> void:
	._start()
	
	enemy.sprite.play("idle")

func _update(_delta: float) -> void:
	._update(_delta)
	
	if enemy.is_on_ground():
		enemy.sprite.play("idle")
	else:
		if enemy.velocity.y > 0:
			enemy.sprite.play("fall")
		else:
			enemy.sprite.play("jump")
	
	var player: Character = enemy.player_detector.get_player()
	if is_instance_valid(player) and not player.dead:
		enemy.set_state_by_name("ChaseState")
