extends EnemyState


onready var animation_player = $"%AnimationPlayer"


func _start() -> void:
	enemy.z_index = -3
	enemy.velocity.x = 0
	animation_player.play("crumble")
	enemy.call_deferred("set_collision_layer_bit", 2, false)


func _stop() -> void:
	enemy.z_index = -2
	enemy.call_deferred("set_collision_layer_bit", 2, true)
