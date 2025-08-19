extends EnemyStopState


onready var animation_player = get_node("%AnimationPlayer")


func _start():
	enemy.velocity.y /= 4
	
	# animations are played in the damage component for bullies to reduce copied states/code
	
	yield(animation_player, "animation_finished")
	enemy.queue_free()


func spawn_coin(arc_to_player: bool = true):
	if arc_to_player:
		var target = enemy.player_detector.get_player_from_world(Vector2(512, INF))
		var target_position := enemy.global_position + Vector2(192 * (round(rand_range(0, 1)) * 2 - 1), -192)
		
		if is_instance_valid(target):
			target_position = target.global_position
		
		var coin_velocity := calculate_coin_velocity(enemy.global_position - Vector2(0, -12), target_position, enemy.gravity)
		var coin: GameObject = enemy.create_coin(coin_velocity, Vector2(0, -12))
		coin.toggle_terrain_collision(false)
	else:
		var coin_velocity_x = 80 * (round(rand_range(0, 1)) * 2 - 1)
		enemy.create_coin(Vector2(coin_velocity_x, -300), Vector2(0, -8))


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
