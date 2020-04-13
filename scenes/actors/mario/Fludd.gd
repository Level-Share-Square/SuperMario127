extends Node

class_name Fludd

var character: Character
var activated: bool

func _ready():
	character = get_node("../../")

func handle_update(delta: float):
	if character.controllable:
		if character.inputs[7][0] and character.fuel > 0 and character.stamina > 0:
			_activated_update(delta)
	if character.fludd == self:
		_update(delta)
	_general_update(delta)
	
func _activate_check(_delta: float):
	pass
	
func _update(_delta: float):
	pass
	
func _activated_update(_delta: float):
	pass
	
func _general_update(_delta: float):
	pass
