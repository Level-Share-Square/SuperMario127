extends EnemyState


export var alert_speed_scale: float = 3.5
export var chase_speed_scale: float = 2.25
export var squished_chase_speed_scale: float = 3.25
export var chase_speed: float = 110
export var squished_chase_speed = 160
export var accel: float = 3
export var squished_accel: float = 9

var target_player: Character
var footstep_interval := 0.0
var is_alert: bool = false

onready var player_forgetter: Area2D = get_node("%PlayerForgetter")
onready var wall_detector: RayCast2D = get_node_or_null("Wall")
onready var animation_player = $"%AnimationPlayer"
onready var run_sound = $"%Run"
onready var skid_sound = $"%Skid"


func _start() -> void:
	enable_raycasts(true)
	$"%StompCloudF".emitting = true
	$"%StompCloudB".emitting = true
	if enemy.last_state == $"../SquishStunState" or enemy.last_state == $"../KnockbackState":
		return
	if enemy.is_on_ground():
		jump()
	
	gravity_multiplier = 1.5
	is_alert = true
	enemy.sprite.play("walking")
	animation_player.play("alert")

func _update(delta: float) -> void:
	var cur_accel: float = accel if not enemy.squished else squished_accel
	var cur_chase_speed: float = chase_speed if not enemy.squished else squished_chase_speed
	var cur_speed_scale: float = chase_speed_scale if not enemy.squished else squished_chase_speed_scale
	
	target_player = player_forgetter.get_player()
	
	if not is_instance_valid(target_player) or target_player.dead:
		enemy.set_state_by_name("IdleState")
		enemy.sprite.speed_scale = 1
		return
	
	if enemy.is_on_ground():
		gravity_multiplier = 1.0
		is_alert = false
		if enemy.sprite.animation != "skid" or not should_skid():
			enemy.sprite.play("walking")
		
			if footstep_interval <= 0:
				run_sound.play()
				footstep_interval = 0.5 / enemy.sprite.speed_scale
			footstep_interval -= delta
	else:
		if enemy.sprite.animation != "skid" or not should_skid():
			if not is_alert:
				enemy.sprite.play("airborne")
	
	if is_alert:
		enemy.sprite.speed_scale = alert_speed_scale
	elif enemy.sprite.animation == "walking":
		enemy.sprite.speed_scale = move_toward(enemy.sprite.speed_scale, cur_speed_scale, delta * cur_accel * 60)
	else:
		enemy.sprite.speed_scale = 1
	
	var last_facing_dir: int = enemy.facing_direction
	enemy.facing_direction = sign(target_player.global_position.x - enemy.global_position.x)
	
	if not is_alert:
		enemy.velocity.x = move_toward(enemy.velocity.x, enemy.facing_direction * cur_chase_speed, delta * cur_accel * 60)
	
	if enemy.is_on_ground() and enemy.facing_direction != last_facing_dir and enemy.sprite.animation == "walking":
		if abs(enemy.velocity.x) > 70 and should_skid():
			skid_sound.play()
			enemy.sprite.play("skid")
	
	if is_instance_valid(wall_detector):
		wall_detector.cast_to.x = abs(wall_detector.cast_to.x) * enemy.facing_direction
		
		if wall_detector.is_colliding():
			enemy.velocity.x = -enemy.facing_direction


func _stop() -> void:
	gravity_multiplier = 1.0
	is_alert = false
	$"%StompCloudF".emitting = false
	$"%StompCloudB".emitting = false
	enable_raycasts(false)
	enemy.last_state = self


func enable_raycasts(is_enabled: bool) -> void:
	wall_detector.set_deferred("enabled", is_enabled)


func jump() -> void:
	enemy.velocity.y = -225
	enemy.position.y -= 1


func should_skid() -> bool:
	return not is_zero_approx(enemy.velocity.x) and sign(enemy.velocity.x) != enemy.facing_direction
