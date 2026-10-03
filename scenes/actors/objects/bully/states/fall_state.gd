extends EnemyState


var target: Node2D


func _start() -> void:
	enemy.sprite.play("fall")


func _update(delta: float) -> void:
	if enemy.is_on_ground():
		enemy.set_state_by_name("IdleState")
