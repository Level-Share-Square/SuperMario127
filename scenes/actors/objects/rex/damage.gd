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
	if enemy.squished:
		enemy.set_state_by_name("DieState")
	else:
		enemy.set_state_by_name("SquishStunState")


func strong_hurt(body: PhysicsBody2D = null) -> void:
	if is_instance_valid(body):
		var normal := (enemy.global_position - body.global_position).sign().x
		enemy.velocity = Vector2(normal * 84, -84)
	
	if not hit_sound.playing:
		hit_sound.play()
	enemy.set_state_by_name("KnockbackState")


func spin_attacked(body: PhysicsBody2D = null) -> void:
	if enemy.rainbow:
		knock_player(body, true)
		body.invulnerable_frames = 60
		return
	
	if not enemy.state == enemy.get_state_by_name("DieState"):
		strong_hurt(body)


func attack_area_entered(area):
	if not enemy.enabled: return
	if area.has_method("is_hurt_area"):
		if not is_instance_valid(enemy.state) or enemy.state.can_be_hurt:
			spin_attacked(area.get_character())
	elif area is CharacterHitbox:
		var character: Character = area.get_character()
		
		if not is_instance_valid(enemy.state) or enemy.state.can_be_hurt:
			if character.attacking:
				if character.state == character.get_state_node("DiveState") or character.state == character.get_state_node("SlideState"):
					bonk_player(character, true)
				spin_attacked(character)
				
			if character.invincible:
				magicked(character)
			
		if not is_instance_valid(enemy.state) or enemy.state.can_attack:
			# lets not hurt the player if theyre stomping,,
			if character.velocity.y > 0 or character.attacking:
				return
			else:
				damage_player(character)

func ground_pound(body: PhysicsBody2D = null) -> void:
	if enemy.rainbow:
		if not bump_sound.playing:
			bump_sound.play()
			enemy.sprite.modulate = Color.white * 1.5
			enemy.sprite.scale = Vector2.ONE * 1.2
		bounce_player(body)
		return
	
	if not enemy.squished:
		enemy.get_state_by_name("DieState").animation = "pound_squish"
	enemy.set_state_by_name("DieState")


func shelled(body: PhysicsBody2D) -> void:
	strong_hurt(body)


func incinerated() -> void:
	hurt()

