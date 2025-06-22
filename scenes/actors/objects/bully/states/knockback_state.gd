extends EnemyState


func _update(delta: float):
	if enemy.velocity.length_squared() < 2500 and enemy.is_on_floor():
		enemy.sprite.rotation = 0
		enemy.set_state_by_name("IdleState")
	
	if enemy.is_on_floor():
		enemy.velocity.x = move_toward(enemy.velocity.x, 0, delta * 5 * 60)
