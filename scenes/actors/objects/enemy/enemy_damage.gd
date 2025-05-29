class_name EnemyDamage
extends Node2D


enum BounceType {NORMAL, SPRING}

## not type hinted as an EnemyBase cuz cyclic dependancy
onready var enemy: KinematicBody2D = get_owner()

export var health: int = 1
export var damage: int = 1

export(BounceType) var bounce_type: int = 0
export var bounce_power: float = 330
export var spring_bounce_windup_length: float = 0.15
export var spring_bounce_depth: float = 6



onready var attack_area = get_node_or_null("Attack") 
onready var stomp_area = get_node_or_null("Stomp")
onready var crush_area = get_node_or_null("Crush")

## sorry but this has to be done, we don't want mario to be able to stand inside an enemy
func _physics_process(delta):
	if attack_area.get_overlapping_areas().size() > 0:
		var areas = attack_area.get_overlapping_areas()
		for area in areas:
			attack_area_entered(area)


## default (mario, shells)
func hurt() -> void:
	pass


## steelies
func strong_hurt() -> void:
	hurt()


## being jumped on
func stomp() -> void:
	hurt()


## self explanatory
func spin_attacked() -> void:
	hurt()


## self explanatory
func ground_pound() -> void:
	strong_hurt()


## bob-ombs
## doesnt function, need to change how explosions work
func exploded() -> void:
	strong_hurt()


## fire
## doesnt function, need ability to distinguish lava and fire
func burnt() -> void:
	pass


## lava
## doesnt function, need ability to distinguish lava and fire
func incinerated() -> void:
	strong_hurt()


## metal and rainbow mario
func magicked() -> void:
	strong_hurt()


## self explanatory
func crushed() -> void:
	strong_hurt()


## get off me mario!!
func damage_player(character: Character) -> void:
	character.damage_with_knockback(global_position, damage)


func bounce_player(character: Character) -> void:
	match(bounce_type):
		BounceType.NORMAL:
			if character.state != character.get_state_node("DiveState"):
				character.set_state_by_name("BounceState", 0)
			character.velocity.y = -bounce_power
		
		BounceType.SPRING:
			if character.state != character.get_state_node("DiveState"):
				character.set_state_by_name("BounceState", 0)
			
			character.velocity.y = 0
			character.movable = false
			character.enemy_collision.monitorable = false
			if character.move_direction != 0:
				character.global_position.x += character.move_direction * 2
			
			var tween: SceneTreeTween = get_tree().create_tween()
			tween.set_trans(Tween.TRANS_QUAD)
			tween.tween_property(character, "global_position:y", character.global_position.y + spring_bounce_depth, spring_bounce_windup_length / 2.0)
			yield(tween, "finished")
			
			tween = get_tree().create_tween()
			tween.set_trans(Tween.TRANS_LINEAR)
			tween.tween_property(character, "global_position:y", character.global_position.y - spring_bounce_depth, spring_bounce_windup_length / 2.0)
			yield(tween, "finished")
			
			character.enemy_collision.monitorable = true
			character.movable = true
			character.velocity.y = -bounce_power
			


## collision detection methods
func attack_body_entered(body) -> void:
	if not enemy.enabled: return
	
	if not is_instance_valid(enemy.state) or enemy.state.can_be_hurt:
		if body.name == "Steely":
			strong_hurt()


func attack_area_entered(area):
	if area.has_method("is_hurt_area"):
		spin_attacked()
	elif area is CharacterHitbox:
		var character: Character = area.get_character()
		
		if not is_instance_valid(enemy.state) or enemy.state.can_be_hurt:
			if character.attacking:
				spin_attacked()
			
			if character.invincible:
				magicked()
			
		if not is_instance_valid(enemy.state) or enemy.state.can_attack:
			# lets not hurt the player if theyre stomping,,
			if character.velocity.y > 0 or character.attacking: 
				return
			
			damage_player(character)


func stomp_area_entered(area: Area2D) -> void:
	if not enemy.enabled: return
	if is_instance_valid(enemy.state) and not enemy.state.can_be_hurt: return
	
	var character: Character
	if area is CharacterHitbox:
		character = area.get_character()
	
	if is_instance_valid(character):
		if character.velocity.y > 0 and not character.swimming:
			if character.invincible:
				magicked()
				bounce_player(character)
			elif character.big_attack:
				ground_pound()
			else:
				stomp()
				bounce_player(character)


## if terrain manages to touch this, our enemy has probably been squished...
func crush_body_entered(body):
	crushed()
