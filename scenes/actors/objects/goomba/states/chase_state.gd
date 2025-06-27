extends EnemyState


export var move_speed: float = 16
export var chase_speed: float = 24
export var accel: float = 2

var target_player: Character

onready var player_detector: Area2D = get_node("%PlayerDetector")
onready var ledge_detector: RayCast2D = get_node_or_null("Ledge")
onready var wall_detector: RayCast2D = get_node_or_null("Wall")


func _start() -> void:
	enable_raycasts(true)
	
	jump()


func _update(delta: float) -> void:
	target_player = player_detector.get_player()
	
	if not is_instance_valid(target_player) or target_player.dead:
		enemy.set_state_by_name("WanderState")
		enemy.sprite.speed_scale = 1
		return
	
	if enemy.is_on_ground():
		enemy.sprite.play("walk")
		
		if is_instance_valid(ledge_detector):
			ledge_detector.position.x = abs(ledge_detector.position.x) * enemy.facing_direction
			
			if not ledge_detector.is_colliding():
				jump()
	else:
		if enemy.velocity.y > 0:
			enemy.sprite.play("fall")
		else:
			enemy.sprite.play("jump")
	
	
	if is_instance_valid(wall_detector):
		wall_detector.cast_to.x = abs(wall_detector.cast_to.x) * enemy.facing_direction
		
		if wall_detector.is_colliding():
			enemy.facing_direction = -enemy.facing_direction
			enemy.velocity.x = enemy.facing_direction
	
	enemy.facing_direction = sign(target_player.global_position.x - enemy.global_position.x)
	enemy.sprite.speed_scale = move_toward(enemy.sprite.speed_scale, chase_speed / move_speed, delta * accel * 60)
	enemy.velocity.x = move_toward(enemy.velocity.x, enemy.facing_direction * chase_speed, delta * accel * 60)


func _stop() -> void:
	enable_raycasts(false)


func enable_raycasts(is_enabled: bool) -> void:
	ledge_detector.set_deferred("enabled", is_enabled)
	wall_detector.set_deferred("enabled", is_enabled)


func jump() -> void:
	enemy.velocity.y = -225
