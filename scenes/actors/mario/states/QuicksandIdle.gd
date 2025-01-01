class_name QuicksandIdleState
extends State

export var fall_speed : float = 30.0
export var jump_length : int = 5

var move_speed_modifier : float = 0.75

func _ready():
	priority = 5
	blacklisted_states = ["BounceState", "GetupState"]

func _start_check(_delta):
	for area in character.liquid_detector.get_overlapping_areas():
		var liquid : LiquidBase = area.get_parent()
		if liquid.liquid_type == liquid.LiquidType.Quicksand:
			return true

func _start(delta):
	pass

func _update(delta):
	character.velocity = Vector2(character.velocity.x*move_speed_modifier, fall_speed*3)
	
	if abs(character.velocity.x) > 15:
		if !character.is_walled():
			character.sprite.speed_scale = .75
			character.sprite.animation = "movingRight" if character.facing_direction == 1 else "movingLeft"
		else:
			character.sprite.speed_scale = 0
			character.sprite.animation = "idleRight" if character.facing_direction == 1 else "idleLeft"
		
		if character.footstep_interval <= 0 and character.sprite.speed_scale > 0:
			character.sound_player.play_footsteps()
			character.footstep_interval = clamp(0.8 - (character.sprite.speed_scale / 2.5), 0.1, 1)
		
		character.footstep_interval -= delta
	else:
		if !character.disable_animation and character.movable and character.controlled_locally:
			character.sprite.speed_scale = 1
			character.sprite.animation = "idleRight" if character.facing_direction == 1 else "idleLeft"

func _stop_check(_delta):
	for area in character.liquid_detector.get_overlapping_areas():
		var liquid : LiquidBase = area.get_parent()
		if liquid.liquid_type == liquid.LiquidType.Quicksand:
			return false
	return true
