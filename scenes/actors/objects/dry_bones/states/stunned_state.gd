extends EnemyStopState


onready var animation_player = $"%AnimationPlayer"


func _start() -> void:
	enemy.velocity.x = 0
	animation_player.play("stunned")
