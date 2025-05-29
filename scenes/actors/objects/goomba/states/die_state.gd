extends EnemyStopState


onready var animation_player = get_node("%AnimationPlayer")


func _start():
	enemy.velocity.x = 0
	get_node("%IdleTimer").stop()
	get_node("%WanderTimer").stop()
	
	animation_player.play("squish")
