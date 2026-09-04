extends EnemyState


onready var hit_sound = $"%Hit"
export var anim_name: String = "knockback"
export var velocity_threshold = 2500 


func _start() -> void:
	._start()
	hit_sound.play()
	enemy.sprite.scale = Vector2.ONE * 1.15
	enemy.sprite.modulate = Color.white * 1.25
	enemy.sprite.play(anim_name)


func _update(delta: float):
	if enemy.velocity.length_squared() < velocity_threshold and enemy.is_on_ground():
		enemy.sprite.rotation = 0
		enemy.set_state_by_name("IdleState")
	
	if enemy.is_on_ground():
		enemy.velocity.x = move_toward(enemy.velocity.x, 0, delta * 3 * 60)
