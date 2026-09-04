class_name EnemyDamage
extends Node2D


enum BounceType {NORMAL, SPRING}

## not type hinted as an EnemyBase cuz cyclic dependancy
onready var enemy: KinematicBody2D = get_owner()

export var health: int = 1
export var damage: int = 1
export var knockback_power := Vector2(225, 235)
export var set_player_knockback_state: bool = true

export(BounceType) var bounce_type: int = 0
export var bounce_power: float = 330
export var big_bounce_power: float = 400
export var spring_bounce_windup_length: float = 0.15
export var spring_bounce_depth: float = 14
export var spring_bounce_pause_length: float = 0.15

onready var attack_area = get_node_or_null("Attack") 
onready var stomp_area = get_node_or_null("Stomp")
onready var crush_area = get_node_or_null("Crush")


var listening_character: Character
var is_boosted: bool

var level_bounds: Rect2


func _ready():
	level_bounds = CurrentLevelData.current_area.header.bounds
	enemy.damage = self


## sorry but this has to be done, we don't want mario to be able to stand inside an enemy
func _physics_process(delta):
	if not attack_area.get_overlapping_areas().empty():
		var areas = attack_area.get_overlapping_areas()
		for area in areas:
			attack_area_entered(area)
	
	if enemy.liquids_detector.monitoring and not enemy.liquids_detector.get_overlapping_areas().empty():
		check_liquid_area()
	
	if enemy.global_position.y > (level_bounds.end.y * 32) + 128:
		pit()
	
	if is_instance_valid(listening_character) and listening_character.inputs[listening_character.input_names.jump][1]:
		listening_character.sprite.modulate = Color.white * 1.5
		is_boosted = true


## default (mario, shells)
func hurt(body: PhysicsBody2D = null) -> void:
	pass


## steelies
func strong_hurt(body: PhysicsBody2D = null) -> void:
	hurt(body)


## being jumped on
func stomp(body: PhysicsBody2D = null) -> void:
	hurt(body)


## self explanatory
func spin_attacked(body: PhysicsBody2D = null) -> void:
	hurt(body)


## self explanatory
func ground_pound(body: PhysicsBody2D = null) -> void:
	strong_hurt(body)


## bob-ombs
## doesnt function, need to change how explosions work
func exploded(body: PhysicsBody2D = null) -> void:
	strong_hurt(body)


## fire
## doesnt function
func burnt() -> void:
	pass


## lava
func incinerated() -> void:
	pass


## metal and rainbow mario
func magicked(body: PhysicsBody2D = null) -> void:
	strong_hurt(body)


## self explanatory
func crushed(body: PhysicsBody2D = null) -> void:
	strong_hurt(body)


func pit() -> void:
	queue_free()


## get off me mario!!
func damage_player(character: Character) -> void:
	if enemy.enabled:
		if damage > 0:
			character.damage_with_knockback(global_position, damage)
		else:
			character.knockback(global_position, knockback_power, set_player_knockback_state)


func knock_player(character: Character, play_hit_sound: bool = false) -> void:
	if enemy.enabled:
		character.knockback(global_position, knockback_power, set_player_knockback_state, play_hit_sound)


func bounce_player(character: Character) -> void:
	match(bounce_type):
		BounceType.NORMAL:
			if character.state != character.get_state_node("DiveState"):
				character.set_state_by_name("BounceState", 0)
			character.velocity.y = -bounce_power
		
		BounceType.SPRING:
			var top_y: float = global_position.y - enemy.enemy_size.y - character.foot_offset
			if character.state != character.get_state_node("DiveState"):
				character.set_state_by_name("BounceState", 0)
			else:
				top_y += 16
			
			character.velocity.y = 0
			character.get_state_node("BounceState").auto_flip = true
			character.movable = false
			character.sprite.animation = "stomp"
			character.enemy_collision.set_deferred("monitorable", false)
			if character.move_direction != 0:
				character.global_position.x += character.move_direction * 2
			
			is_boosted = false
			listening_character = character
			
			var tween: SceneTreeTween = get_tree().create_tween()
			tween.set_trans(Tween.TRANS_QUAD)
			tween.tween_property(character, "global_position:y", top_y + spring_bounce_depth, spring_bounce_windup_length / 2.0)
			tween.tween_property(character.sprite, "frame", 1, spring_bounce_windup_length / 2.0)
			yield(tween, "finished")
			
			tween = get_tree().create_tween()
			tween.set_trans(Tween.TRANS_LINEAR)
			tween.tween_interval(spring_bounce_pause_length)
			yield(tween, "finished")
			
			tween = get_tree().create_tween()
			tween.set_trans(Tween.TRANS_LINEAR)
			tween.tween_property(character, "global_position:y", top_y - spring_bounce_depth, spring_bounce_windup_length / 2.0)
			yield(tween, "finished")
			
			tween = get_tree().create_tween()
			if is_boosted:
				tween.tween_callback(character.sound_player, "play_spring_sound")
				tween.set_parallel(true)
				tween.tween_property(character.sprite, "modulate", Color.white, spring_bounce_windup_length / 2.0)
			tween.tween_property(character.sprite, "frame", 4, spring_bounce_windup_length / 2.0)
			listening_character = null
			
			yield(tween, "finished")
			
			LastInputDevice.rumble(0.5, 0.0, 0.05)
			character.enemy_collision.set_deferred("monitorable", true)
			character.movable = true
			character.get_state_node("BounceState").auto_flip = false
			character.velocity.y = -bounce_power if not is_boosted else -big_bounce_power
			if is_boosted:
				character.velocity.x *= 1.25


## collision detection methods
func attack_body_entered(body) -> void:
	if not enemy.enabled: return
	
	if not is_instance_valid(enemy.state) or enemy.state.can_be_hurt:
		if body.name == "Steely":
			strong_hurt(body)


func attack_area_entered(area):
	if not enemy.enabled: return
	if area.has_method("is_hurt_area"):
		spin_attacked(area.get_character())
	elif area is CharacterHitbox:
		var character: Character = area.get_character()
		
		if not is_instance_valid(enemy.state) or enemy.state.can_be_hurt:
			if character.attacking:
				spin_attacked(character)
			
			if character.invincible:
				magicked(character)
			
		if not is_instance_valid(enemy.state) or enemy.state.can_attack:
			# lets not hurt the player if theyre stomping,,
			if character.velocity.y > 0 or character.attacking:
				return
			else:
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
				magicked(character)
				bounce_player(character)
			elif character.big_attack:
				ground_pound(character)
			else:
				stomp(character)
				bounce_player(character)


func check_liquid_area() -> void:
	var areas = attack_area.get_overlapping_areas()
	for area in areas:
		if area.get_parent() is LiquidBase:
			var liquid: LiquidBase = area.get_parent()
			match liquid.liquid_type:
				LiquidBase.LiquidType.Lava:
					incinerated()


## if terrain manages to touch this, our enemy has probably been squished...
func crush_body_entered(body):
	crushed()
