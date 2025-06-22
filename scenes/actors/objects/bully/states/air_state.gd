extends EnemyState


func _start() -> void:
	enemy.sprite.play("fall")


func _update(delta: float) -> void:
	if enemy.is_on_floor():
		enemy.set_state_by_name("IdleState")
