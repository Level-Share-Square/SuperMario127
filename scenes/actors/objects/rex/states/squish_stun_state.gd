extends EnemyStopState

onready var animation_player = $"%AnimationPlayer"

func _start() -> void:

	animation_player.play("squish_0")
	yield(animation_player, "animation_finished")
	
	if is_instance_valid(enemy.last_state): 
		enemy.set_state_node(enemy.last_state)
	else:
		enemy.set_state_by_name("IdleState")

func _stop() -> void:
	enemy.last_state = self
