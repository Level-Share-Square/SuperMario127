extends EnemyState


onready var hit_sound = $"%Hit"


func _start() -> void:
	._start()
	hit_sound.play()
	enemy.sprite.scale *= 1.15
	enemy.sprite.modulate *= 1.15
	enemy.sprite.play("knockback")


func _update(delta: float):
	if enemy.velocity.length_squared() < 2500 and enemy.is_on_floor():
		enemy.sprite.rotation = 0
		enemy.set_state_by_name("IdleState")
	
	if enemy.is_on_floor():
		enemy.velocity.x = move_toward(enemy.velocity.x, 0, delta * 3 * 60)
