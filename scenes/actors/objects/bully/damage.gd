extends EnemyDamage


func stomp(body: PhysicsBody2D = null) -> void:
	if is_instance_valid(body):
		var normal: float = (enemy.global_position - body.global_position).sign().x
		enemy.velocity = Vector2(normal * 150, 0)
	
	enemy.set_state_by_name("KnockbackState")


func spin_attacked(body: PhysicsBody2D = null) -> void:
	if enemy.state == enemy.get_state_by_name("KnockbackState"):
		return
	
	if is_instance_valid(body):
		var normal: float = (enemy.global_position - body.global_position).sign().x
		enemy.velocity = Vector2(normal * 84 * max(1.0, abs(body.velocity.x / 196.0)), -150)
	
	enemy.set_state_by_name("KnockbackState")


func ground_pound(body: PhysicsBody2D = null) -> void:
	if is_instance_valid(body):
		var normal: float = (enemy.global_position - body.global_position).sign().x
		enemy.velocity = Vector2(normal * 250, 0)
	
	enemy.set_state_by_name("KnockbackState")


func incinerated() -> void:
	enemy.set_state_by_name("DieState")


func pit() -> void:
	incinerated()
