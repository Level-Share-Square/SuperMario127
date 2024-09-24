extends Node

class_name Nozzle

var character: Character
var activated: bool
var override_rotation: bool
var blacklisted_states = []

var last_activated: bool
var last_state = null

var display_stamina: bool
var stamina_value: float 

export var frames : SpriteFrames
export var frames_luigi : SpriteFrames

export var animation_water_positions = {}
export var fallback_water_pos_left : Vector2
export var fallback_water_pos_right : Vector2

export var animation_water_positions_luigi = {}
export var fallback_water_pos_left_luigi : Vector2
export var fallback_water_pos_right_luigi : Vector2

func _ready():
	character = get_node("../../")

func handle_update(delta: float):
	if character.nozzle == self:
		_update(delta)
		if character.controllable:
			if character.inputs[7][0] and !character.inputs[4][0] and _activate_check(delta) and character.fuel > 0 and character.stamina > 0:
				var can_activate = true
				for state in blacklisted_states:
					if character.state == character.get_state_node(state):
						can_activate = false
				if can_activate:
					activated = true
					_activated_update(delta)
				else:
					activated = false
			else:
				activated = false
		else:
			activated = false
	else:
		activated = false
	_general_update(delta)
	
func _activate_check(_delta: float):
	pass
	
func _update(_delta: float):
	pass
	
func _activated_update(_delta: float):
	pass
	
func _general_update(_delta: float):
	pass
