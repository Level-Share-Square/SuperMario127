class_name TouchCheck
extends Node


var character: Character


func _check() -> bool:
	if not is_instance_valid(character):
		character = get_owner().character
	return true
