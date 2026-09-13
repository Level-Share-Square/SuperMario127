extends EnemyStopState


func _start() -> void:
	._start()
	
	if enemy.is_on_ground():
		enemy.sprite.play("idle")
	else:
		enemy.sprite.play("airborne")

func _stop():
	var player: Character = enemy.player_detector.get_player()
	if enemy.last_state == $"../KnockbackState" and is_instance_valid(player) and not player.dead:
		return
	enemy.last_state = self

func _update(_delta: float) -> void:
	._update(_delta)
	
	if enemy.is_on_ground():
		enemy.sprite.play("idle")
	else:
		enemy.sprite.play("airborne")
	
	var player: Character = enemy.player_detector.get_player()
	if is_instance_valid(player) and not player.dead:
		enemy.set_state_by_name("ChaseState")
