extends EnemyDamage


onready var grunt_sound = $"%Grunt"
onready var bonk_sound = $"%Bonk"

export var bully_jump_knockback: Vector2 = Vector2(150, 0)
export var bully_spin_knockback: Vector2 = Vector2(84, -150)
export var bully_gp_knockback: Vector2 = Vector2(200, 0)
export var bully_ram_knockback: Vector2 = Vector2(100, 0)

export var player_knockback := Vector2(225, 235)
export var player_spin_knockback_mult := Vector2(1, 0.75)


func stomp(body: PhysicsBody2D = null) -> void:
	if enemy.rainbow: 
		bonk_sound.play()
		enemy.sprite.modulate = Color(2, 2, 2)
		return
	if is_instance_valid(body):
		var direction: float = (enemy.global_position - body.global_position).sign().x
		enemy.velocity = Vector2(direction * bully_jump_knockback.x, bully_jump_knockback.y)
	enemy.set_state_by_name("KnockbackState")


func spin_attacked(body: PhysicsBody2D = null) -> void:
	if enemy.rainbow:
		if is_instance_valid(body) and body is Character:
			damage_player(body)
		return
	if enemy.state == enemy.get_state_by_name("KnockbackState") or  enemy.state == enemy.get_state_by_name("RamKnockbackState"):
		return
	
	if is_instance_valid(body):
		if body is Character:
			if body.state == body.get_state_node("DiveState") or body.state == body.get_state_node("SlideState"):
				dived(body)
				return
			knock_player(body, player_knockback * player_spin_knockback_mult)
		
		var direction: float = (enemy.global_position - body.global_position).sign().x
		enemy.velocity = Vector2(direction * bully_spin_knockback.x, bully_spin_knockback.y)
	
	enemy.set_state_by_name("KnockbackState")


func ground_pound(body: PhysicsBody2D = null) -> void:
	if enemy.rainbow:
		if is_instance_valid(body) and body is Character:
			damage_player(body)
		return
	
	if is_instance_valid(body):
		var direction: float = (enemy.global_position - body.global_position).sign().x
		enemy.velocity = Vector2(direction * bully_gp_knockback.x, bully_gp_knockback.y)
	enemy.set_state_by_name("KnockbackState")


func magicked(body: PhysicsBody2D = null) -> void:
	if is_instance_valid(body):
		var direction: float = (enemy.global_position - body.global_position).sign().x
		enemy.velocity = Vector2(direction * bully_jump_knockback.x, bully_jump_knockback.y)
	enemy.set_state_by_name("KnockbackState")


func dived(player: Character):
	damage_player(player)


func damage_player(player: Character, knockback: Vector2 = player_knockback, make_bonked: bool = true) -> void:
	knockback_power = knockback
	.damage_player(player)
	if make_bonked:
		bonk_sound.play()
		grunt_sound.play()
		enemy.sprite.modulate = Color(2, 2, 2)
		player.set_state_by_name("BonkedState")
	
	if enemy.rainbow: return
	if is_instance_valid(player):
		var direction: float = (enemy.global_position - player.global_position).sign().x
		enemy.velocity = Vector2(direction * bully_ram_knockback.x, bully_ram_knockback.y)
	
	if make_bonked:
		enemy.set_state_by_name("RamKnockbackState")
	else:
		enemy.set_state_by_name("KnockbackState")


func knock_player(player: Character, knockback: Vector2 = player_knockback) -> void:
	knockback_power = knockback
	.knock_player(player)



func incinerated() -> void:
	enemy.animation_player.play("incinerated")
	enemy.set_state_by_name("DieState")


func pit() -> void:
	enemy.animation_player.play("pit")
	enemy.set_state_by_name("DieState")


func check_liquid_area() -> void:
	var areas = attack_area.get_overlapping_areas()
	for area in areas:
		if area.get_parent() is LiquidBase:
			var liquid: LiquidBase = area.get_parent()
			match liquid.liquid_type:
				LiquidBase.LiquidType.Lava:
					incinerated()
				LiquidBase.LiquidType.Quicksand:
					incinerated()
