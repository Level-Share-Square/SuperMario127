class_name EnemyDamage
extends Node2D


## not type hinted as an EnemyBase cuz cyclic dependancy
onready var enemy: KinematicBody2D = get_owner()

export var health: int = 1
export var damage: int = 1
export var bounce_power: float = 330

onready var attack_area = get_node_or_null("Attack") 
onready var stomp_area = get_node_or_null("Stomp")
onready var crush_area = get_node_or_null("Crush")


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
	if character.state != character.get_state_node("DiveState"):
		character.set_state_by_name("BounceState", 0)
	character.velocity.y = -bounce_power


## collision detection methods
func attack_body_entered(body) -> void:
	if not enemy.enabled: return
	
	if not is_instance_valid(enemy.state) or enemy.state.can_be_hurt:
		if body is Character and body.attacking:
			spin_attacked()
		
		if body is Character and body.invincible:
			magicked()
		
		if body.name == "Steely":
			strong_hurt()
	
	if not is_instance_valid(enemy.state) or enemy.state.can_attack:
		if body is Character:
			# lets not hurt the player if theyre stomping,,
			if body.velocity.y > 0 or body.attacking: return
			damage_player(body)


func attack_area_entered(area):
	if area.has_method("is_hurt_area"):
		spin_attacked()


func stomp_body_entered(body) -> void:
	if not enemy.enabled: return
	if is_instance_valid(enemy.state) and not enemy.state.can_be_hurt: return
	
	if body is Character:
		if body.velocity.y > 0 and not body.swimming:
			if body.invincible:
				magicked()
				bounce_player(body)
			elif body.big_attack:
				ground_pound()
			else:
				stomp()
				bounce_player(body)


## if terrain manages to touch this, our enemy has probably been squished...
func crush_body_entered(body):
	crushed()
