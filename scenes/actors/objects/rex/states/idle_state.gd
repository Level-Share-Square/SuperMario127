extends EnemyStopState


func _start() -> void:
	._start()
	
	enemy.sprite.play("default" if not enemy.squished else "squished")

func _stop():
	var player: Character = enemy.player_detector.get_player()
	if enemy.last_state == $"../KnockbackState" and is_instance_valid(player) and not player.dead:
		return
	enemy.last_state = self

func _update(_delta: float) -> void:
	._update(_delta)
	
	if enemy.is_on_ground():
		enemy.sprite.play("default")
	
	var player: Character = enemy.player_detector.get_player()
	if is_instance_valid(player) and not player.dead:
		enemy.set_state_by_name("ChaseState")
