extends EnemyDamage


var hit_position: Vector2


func hurt() -> void:
	enemy.set_state_by_name("DieState")


func strong_hurt() -> void:
	enemy.set_state_by_name("KnockbackState")


func spin_attacked() -> void:
	strong_hurt()


func ground_pound() -> void:
	hurt()


func incinerated() -> void:
	pass
