extends EnemyDamage


export var bully_jump_knockback: Vector2 = Vector2(150, 0)
export var bully_spin_knockback: Vector2 = Vector2(84, -150)
export var bully_gp_knockback: Vector2 = Vector2(250, 0)
export var bully_ram_knockback: Vector2 = Vector2(100, 0)


func stomp(body: PhysicsBody2D = null) -> void:
	if is_instance_valid(body):
		var direction: float = (enemy.global_position - body.global_position).sign().x
		enemy.velocity = Vector2(direction * bully_jump_knockback.x, bully_jump_knockback.y)
	
	enemy.set_state_by_name("KnockbackState")


func spin_attacked(body: PhysicsBody2D = null) -> void:
	if enemy.state == enemy.get_state_by_name("KnockbackState"):
		return
	
	print(body)
	
	if is_instance_valid(body):
		if body is Character:
			if body.state == body.get_state_node("DiveState") or body.state == body.get_state_node("SlideState"):
				dived(body)
				return
		
		var direction: float = (enemy.global_position - body.global_position).sign().x
		enemy.velocity = Vector2(direction * bully_spin_knockback.x, bully_spin_knockback.y)
	
	enemy.set_state_by_name("KnockbackState")


func ground_pound(body: PhysicsBody2D = null) -> void:
	if is_instance_valid(body):
		var direction: float = (enemy.global_position - body.global_position).sign().x
		enemy.velocity = Vector2(direction * bully_gp_knockback.x, bully_gp_knockback.y)
	
	enemy.set_state_by_name("KnockbackState")


func magicked(body: PhysicsBody2D = null) -> void:
	enemy.set_state_by_name("InstaDieState")


func dived(player: Character):
	damage_player(player)
	
	if is_instance_valid(player):
		var direction: float = (enemy.global_position - player.global_position).sign().x
		enemy.velocity = Vector2(direction * bully_ram_knockback.x * 1.5, bully_ram_knockback.y)
	
	enemy.set_state_by_name("KnockbackState")


func damage_player(player: Character):
	.damage_player(player)
	
	if is_instance_valid(player):
		var direction: float = (enemy.global_position - player.global_position).sign().x
		enemy.velocity = Vector2(direction * bully_ram_knockback.x, bully_ram_knockback.y)
	
	enemy.set_state_by_name("KnockbackState")


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
