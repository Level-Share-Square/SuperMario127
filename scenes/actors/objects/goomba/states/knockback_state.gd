extends EnemyState


export var friction: float = 8
export var roll_speed: float = 225


func _start():
	enemy.collision_layer = 0
	enemy.sprite.scale = Vector2.ONE * 1.1
	enemy.sprite.modulate = Color.white * 1.25
	enemy.sprite.play("knockback")


func _update(delta: float):
	enemy.sprite.rotation_degrees += (enemy.velocity.x / 15.0)
	
	if enemy.velocity.length_squared() < 2500 and enemy.is_on_ground():
		enemy.sprite.rotation = 0
		enemy.set_state_by_name("DieState")
	
	if enemy.is_on_ground():
		if is_equal_approx(enemy.get_floor_normal().y, -1):
			enemy.velocity.x = move_toward(enemy.velocity.x, 0, delta * friction * 60)
		else:
			var normal: = sign(enemy.get_floor_normal().x)
			enemy.velocity.x = move_toward(enemy.velocity.x, roll_speed * normal, delta * 60)
