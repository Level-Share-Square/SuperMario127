extends Nozzle

class_name HoverNozzle

export var boost_power := 75
export var depletion := 0.25

func _init():
	blacklisted_states = ["WallSlideState", "GroundPoundStartState", "GroundPoundState", "GroundPoundEndState", "GetupState", "BonkedState", "SpinningState"]

func _activate_check(_delta):
	return true
	
func _activated_update(_delta):
	if character.facing_direction == 1:
		character.sprite.animation = "jumpRight"
	else:
		character.sprite.animation = "jumpLeft"
	character.jump_animation = 0
	character.velocity.y = -boost_power * (character.stamina / 100)
	character.stamina -= depletion
	
func _update(_delta):
	if character.is_grounded():
		character.stamina = 100
