extends EnemyState


export var move_speed: float = 24
export var squished_move_speed = 64
export var chase_speed: float = 55
export var squished_chase_speed = 72
export var accel: float = 1
export var squished_accel: float = 8

var target_player: Character
var footstep_interval := 0.0

onready var player_detector: Area2D = get_node("%PlayerDetector")
onready var wall_detector: RayCast2D = get_node_or_null("Wall")
onready var animation_player = $"%AnimationPlayer"
onready var run_sound = $"%Run"


func _start() -> void:
	enable_raycasts(true)
	if enemy.last_state == $"../SquishStunState" or enemy.last_state == $"../KnockbackState":
		return
	if enemy.is_on_ground():
		jump()
	animation_player.play("alert")

func _update(delta: float) -> void:
	var accel = self.accel if not enemy.squished else squished_accel
	var move_speed = self.move_speed if not enemy.squished else squished_move_speed
	var chase_speed = self.chase_speed if not enemy.squished else squished_chase_speed
	
	target_player = player_detector.get_player()
	
	if not is_instance_valid(target_player) or target_player.dead:
		enemy.set_state_by_name("IdleState")
		enemy.sprite.speed_scale = 1
		return
	
	if enemy.is_on_ground():
		enemy.sprite.play("walking" if not enemy.squished else "walking_squished")
		
		if footstep_interval <= 0:
			run_sound.play()
			footstep_interval = 0.3 / enemy.sprite.speed_scale
		footstep_interval -= delta
		
	else:
		if enemy.velocity.y > 0:
			enemy.sprite.play("walking" if not enemy.squished else "walking_squished")
		elif enemy.sprite.animation != "alert":
			enemy.sprite.play("walking" if not enemy.squished else "walking_squished")
	
	if enemy.sprite.animation == "walking" or enemy.sprite.animation == "walking_squished":
		enemy.sprite.speed_scale = move_toward(enemy.sprite.speed_scale, chase_speed / move_speed, delta * accel * 60)
	else:
		enemy.sprite.speed_scale = 1
	
	enemy.facing_direction = sign(target_player.global_position.x - enemy.global_position.x)
	enemy.velocity.x = move_toward(enemy.velocity.x, enemy.facing_direction * chase_speed, delta * accel * 60)
	
	if is_instance_valid(wall_detector):
		wall_detector.cast_to.x = abs(wall_detector.cast_to.x) * enemy.facing_direction
		
		if wall_detector.is_colliding():
			enemy.velocity.x = -enemy.facing_direction


func _stop() -> void:
	enable_raycasts(false)
	enemy.last_state = self


func enable_raycasts(is_enabled: bool) -> void:
	wall_detector.set_deferred("enabled", is_enabled)


func jump() -> void:
	enemy.velocity.y = -225
	enemy.position.y -= 1
