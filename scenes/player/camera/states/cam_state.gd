class_name CamState
extends Node


var camera: Camera2D
var character: Character setget ,_get_character
func _get_character() -> Character:
	return camera.character_node

export var priority: int = -1


func _enter_tree():
	camera = get_owner()


func start_check() -> bool:
	return false


func stop_check() -> bool:
	return false


func start() -> void:
	pass


func stop() -> void:
	pass


func update(_delta: float) -> void:
	pass


func reset_vars() -> void:
	pass


func general_update(_delta: float):
	pass
