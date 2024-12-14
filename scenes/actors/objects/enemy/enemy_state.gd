class_name EnemyState
extends Node


## not type hinted as an EnemyBase cuz cyclic dependancy
onready var enemy: KinematicBody2D = get_owner()

export var can_attack: bool = true
export var can_be_hurt: bool = true
export var gravity_multiplier: float = true


func _start() -> void:
	pass


func _stop() -> void:
	pass


func _update(_delta: float) -> void:
	pass
