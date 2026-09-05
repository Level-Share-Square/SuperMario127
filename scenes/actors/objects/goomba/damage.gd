extends EnemyDamage


onready var hit_sound: AudioStreamPlayer2D = $"%Hit"
onready var bump_sound: AudioStreamPlayer2D = $"%Bump"
var hit_position: Vector2


func hurt(body: PhysicsBody2D = null) -> void:
	if enemy.rainbow and is_instance_valid(body):
		if not bump_sound.playing:
			bump_sound.play()
			enemy.sprite.modulate = Color.white * 1.5
			enemy.sprite.scale = Vector2.ONE * 1.2
		return
	enemy.set_state_by_name("DieState")


func strong_hurt(body: PhysicsBody2D = null) -> void:
	if is_instance_valid(body):
		var normal := (enemy.global_position - body.global_position).sign().x
		enemy.velocity = Vector2(normal * 225, -225)
	
	if not hit_sound.playing:
		hit_sound.play()
	enemy.set_state_by_name("KnockbackState")


func spin_attacked(body: PhysicsBody2D = null) -> void:
	if enemy.rainbow:
		knock_player(body, true)
		body.invulnerable_frames = 30
		return
	if not enemy.state == enemy.get_state_by_name("DieState"):
		strong_hurt(body)
	


func ground_pound(body: PhysicsBody2D = null) -> void:
	if enemy.rainbow:
		if not bump_sound.playing:
			bump_sound.play()
			enemy.sprite.modulate = Color.white * 1.5
			enemy.sprite.scale = Vector2.ONE * 1.2
		bounce_player(body)
		return
	
	enemy.get_state_by_name("DieState").animation = "pound_squish"
	hurt(body)


func shelled(body: PhysicsBody2D) -> void:
	strong_hurt(body)


func incinerated() -> void:
	hurt()
