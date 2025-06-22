extends EnemyStopState


onready var animation_player = get_node("%AnimationPlayer")


func _start():
	enemy.velocity = Vector2.ZERO
	
	animation_player.play("squish")
	
	yield(animation_player, "animation_finished")
	enemy.queue_free()


func spawn_coin():
	var target = enemy.player_detector.get_player_from_world(Vector2(256, INF))
	var target_position := enemy.global_position + Vector2(192 * (round(rand_range(0, 1)) * 2 - 1), -192)
	
	if is_instance_valid(target):
		target_position = target.global_position
	
	var coin_velocity := calculate_coin_velocity(enemy.global_position - Vector2(0, -12), target_position, enemy.gravity)
	enemy.create_coin(coin_velocity, Vector2(0, -12))


func calculate_coin_velocity(source_position: Vector2, target_position: Vector2, gravity: float) -> Vector2:
	var new_velocity := Vector2.ZERO
	var displacement := target_position-source_position
	var arc_height := min((target_position.y-source_position.y-72), -64)-abs(displacement.x/5)
	
	if displacement.y > arc_height:
		var time_up = sqrt(-2 * arc_height/gravity)
		var time_down = sqrt(2 * (displacement.y - arc_height)/gravity)
		
		new_velocity.y = -sqrt(-2 * gravity * arc_height)
		new_velocity.x = displacement.x / (time_up+time_down)
	
	#for some reason dividing by .13 makes the code work perfectly, so we're going to roll with it
	return new_velocity/.125
