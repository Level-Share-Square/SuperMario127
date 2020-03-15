extends Node

class_name State

var character: Character

export var priority = 0
export var disable_movement = false
export var disable_animation = false
export var disable_turning = false
export var blacklisted_states = []

func _ready():
	character = get_node("../../")

func handle_update(delta: float):
	if character.controllable:
		if character.state != self and _start_check(delta):
			var old_priority = -1 if character.state == null else character.state.priority
			var blacklisted = false
			for state_name in blacklisted_states:
				if character.state == character.get_state_node(state_name):
					blacklisted = true
			if self.priority >= old_priority and !blacklisted:
				character.set_state(self, delta)
		if character.state == self:
			_update(delta)
		if character.state == self and _stop_check(delta):
			character.set_state(null, delta)
	_general_update(delta)
func _start_check(delta: float):
	pass
	
func _start(delta: float):
	pass
	
func _update(delta: float):
	pass
	
func _stop_check(delta: float):
	pass
	
func _stop(delta: float):
	pass
	
func _general_update(delta: float):
	pass
