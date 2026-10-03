extends EnemyStopState


onready var animation_player = $"%AnimationPlayer"
export var animation = "squish"


func _start():
	enemy.collision_layer = 0
	enemy.velocity = Vector2.ZERO
	enemy.gravity = 0
	animation_player.play(animation)
	
	yield(animation_player, "animation_finished")
	enemy.queue_free()


func spawn_coin():
	var coin_velocity_x = 80 * (round(rand_range(0, 1)) * 2 - 1)
	enemy.create_coin(Vector2(coin_velocity_x, -300), Vector2(0, -8))
