extends Node

class_name State

var character : Character

export var priority = 0
export var disable_movement = false
export var disable_animation = false
export var disable_turning = false
export var disable_snap = true
export var disable_friction = false
export var disable_knockback = false
export var override_rotation = false
export var attack_tier = 0
export var use_dive_collision = false
export var auto_flip = false
export var blacklisted_states = []

func _ready():
	character = get_node("../../")

func handle_update(delta: float):
	if character.controllable:
		if character.state != self and _start_check(delta) and !character.switching_state:
			var old_priority = -1 if character.state == null else character.state.priority
			if self.priority >= old_priority and !is_in_blacklisted_state():
				character.set_state(self, delta)
		if character.state == self:
			_update(delta)
		if character.state == self and _stop_check(delta):
			character.set_state(null, delta)
	_general_update(delta)

func is_in_blacklisted_state():
	var blacklisted = false
	for state_name in blacklisted_states:
		if character.state == character.get_state_node(state_name) and character.state != null:
			blacklisted = true
	return blacklisted

func _start_check(_delta: float):
	pass
	
func _start(_delta: float):
	pass
	
# called every frame only when the state is active
func _update(_delta: float):
	pass
	
func _stop_check(_delta: float):
	pass
	
func _stop(_delta: float):
	pass
	
# called every frame regardless of if the state is active
func _general_update(_delta: float):
	pass
