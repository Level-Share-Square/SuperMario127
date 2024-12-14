extends EnemyState


export var friction: float = 2


func _start() -> void:
	enemy.sprite.play("idle")


func _update(delta: float) -> void:
	enemy.velocity.x = move_toward(enemy.velocity.x, 0, delta * friction * 60)
