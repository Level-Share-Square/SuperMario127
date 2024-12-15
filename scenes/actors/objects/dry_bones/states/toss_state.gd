extends EnemyStopState


const BONE_STATE: PackedScene = preload("res://scenes/actors/objects/dry_bones/bone/bone.tscn")
export var bone_speed: float = 40
export var toss_offset: Vector2

onready var animation_player = $"%AnimationPlayer"


func _start() -> void:
	enemy.velocity.x = 0
	animation_player.play("toss")


func toss_bone() -> void:
	var bone: Area2D = BONE_STATE.instance()
	bone.position = enemy.position
	bone.position += toss_offset * Vector2(enemy.facing_direction, 1)
	bone.velocity.x = bone_speed * enemy.facing_direction
	enemy.get_parent().call_deferred("add_child", bone)
