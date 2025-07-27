extends EnemyDamage


var hit_position: Vector2


func hurt(body: PhysicsBody2D = null) -> void:
	enemy.set_state_by_name("DieState")


func strong_hurt(body: PhysicsBody2D = null) -> void:
	if is_instance_valid(body):
		var normal := (enemy.global_position - body.global_position).sign().x
		enemy.velocity = Vector2(normal * 225, -225)
	
	enemy.set_state_by_name("KnockbackState")


func spin_attacked(body: PhysicsBody2D = null) -> void:
	if not enemy.state == enemy.get_state_by_name("DieState"):
		strong_hurt(body)
	


func ground_pound(body: PhysicsBody2D = null) -> void:
	hurt(body)


func incinerated() -> void:
	pass
