extends EnemyState


onready var hit_sound: AudioStreamPlayer2D = enemy.get_node("Sounds/Hit")


func _start():
	hit_sound.play()


func _update(delta: float):
	enemy.sprite.rotation_degrees += (enemy.velocity.x / 15.0)
	
	if enemy.velocity.length_squared() < 2500 and enemy.is_on_floor():
		enemy.sprite.rotation = 0
		enemy.set_state_by_name("DieState")
	
	if enemy.is_on_floor():
		if is_equal_approx(enemy.get_floor_normal().y, -1):
			enemy.velocity.x = move_toward(enemy.velocity.x, 0, delta * 5 * 60)
		else:
			var normal: = sign(enemy.get_floor_normal().x)
			enemy.velocity.x = move_toward(enemy.velocity.x, 225 * normal, delta * 60)
