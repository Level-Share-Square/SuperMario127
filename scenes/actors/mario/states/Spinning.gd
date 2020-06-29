extends State

class_name SpinningState

export var boost_power: float = 175
export var gravity_scale: float = 0.5
var old_gravity_scale = 1
var can_boost = true
var cooldown_timer = 0
var spin_timer = 0
var attack_timer = 0

func _ready():
	priority = 2
	disable_animation = true
	blacklisted_states = ["GetupState"]
	attack_tier = 1

func _start_check(_delta):
	return spin_timer > 0 and (character.state == null or character.state != character.get_state_node("DiveState")) and character.jump_animation != 2 and !character.test_move(character.transform, Vector2(8, 0)) and !character.test_move(character.transform, Vector2(-8, 0))

func _start(_delta):
	character.sprite.speed_scale = 1
	if can_boost == true and !character.is_grounded() and (character.state != character.get_state_node("Jump") or character.current_jump == 1):
		can_boost = false
		cooldown_timer = 0.5
		if character.velocity.y > -boost_power:
			if character.velocity.y > 100:
				character.velocity.y /= 1.5
			if character.velocity.y > 0:
				character.velocity.y -= boost_power
			else:
				character.velocity.y -= boost_power/2
	old_gravity_scale = character.gravity_scale
	character.gravity_scale = gravity_scale
	
func _update(_delta):
	var sprite = character.animated_sprite
	if character.is_grounded():
		priority = 0
		disable_snap = false
	else:
		priority = 2
		disable_snap = true
	if sprite.animation != "spinning":
		sprite.animation = "spinning"
	if character.velocity.y < 0:
		character.gravity_scale = old_gravity_scale
	else:
		character.gravity_scale = gravity_scale
		
func _stop(_delta):
	character.gravity_scale = old_gravity_scale
	priority = 2

func _stop_check(_delta):
	return spin_timer == 0 or character.test_move(character.transform, Vector2(8, 0)) or character.test_move(character.transform, Vector2(-8, 0))
	
func _general_update(delta):
	if cooldown_timer > 0:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			cooldown_timer = 0
			can_boost = true
	if spin_timer > 0:
		if character.jump_animation == 2 and character.state == character.get_state_node("JumpState"):
			spin_timer = 0.15
		spin_timer -= delta
		if spin_timer <= 0:
			spin_timer = 0
	if character.inputs[4][0]:
		spin_timer = 0.15
		
		if character.inputs[4][1] and !is_in_blacklisted_state() and (character.state == null or character.state.priority <= priority):
			character.sound_player.play_spin_sound()
	if character.test_move(character.transform, Vector2(8, 0)) or character.test_move(character.transform, Vector2(-8, 0)):
		spin_timer = 0
	if character.is_grounded():
		can_boost = true
		
	if attack_timer > 0:
		attack_timer -= delta
		if attack_timer <= 0:
			attack_timer = 0
			character.attacking = false
