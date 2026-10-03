class_name EnemyStopState
extends EnemyState


export var friction: float = 2
export var air_friction: float = 1


func _update(delta: float) -> void:
	var working_friction = friction if enemy.is_on_ground() else air_friction
	
	enemy.velocity.x = move_toward(enemy.velocity.x, 0, delta * working_friction * 60)
