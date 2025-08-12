extends EnemyWanderState


func _start() -> void:
	._start()
	
	var walk_anim_frame_count: float = enemy.sprite.frames.get_frame_count("walk")
	var walk_anim_fps: float = enemy.sprite.frames.get_animation_speed("walk")

	time = stepify(time, walk_anim_fps / walk_anim_frame_count)


func _update(delta: float) -> void:
	._update(delta)
	
	if enemy.is_on_ground():
		enemy.sprite.play("walk")
		pass
	else:
		if enemy.velocity.y > 0:
			enemy.sprite.play("fall")
		else:
			enemy.sprite.play("jump")
	
	if is_instance_valid(enemy.player_detector.get_player()):
		enemy.set_state_by_name("ChaseState")
