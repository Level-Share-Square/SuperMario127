extends State

class_name SpinningState

export var boost_power: float = 175
export var gravity_scale: float = 0.5
export var attack_time: float = 0.5
var old_gravity_scale = 1
var spin_timer := 0.0
var boost_cooldown_timer := 0.0
var spin_disable_time := 0.0
var attack_timer := 0.0
var sound_buffer := 0.0

func _ready():
	priority = 2
	disable_animation = true
	blacklisted_states = ["GetupState", "WallSlideState"]

func _start_check(_delta):
	return !(character.is_grounded() and character.rainbow_stored) and boost_cooldown_timer == 0 and spin_timer > 0 and (character.state == null or character.state != character.get_state_node("DiveState")) and character.jump_animation != 2

func _start(_delta):
	character.ring_particles.animation = "twirl"
	character.ring_particles.frame = 0
	attack_timer = attack_time
	character.spin_area_shape.disabled = false
	if sound_buffer > 0:
		character.sound_player.play_spin_sound()
	sound_buffer = 0
	if !character.is_grounded() and (character.state != character.get_state_node("Jump") or character.current_jump == 1):
		if character.velocity.y > -boost_power and boost_cooldown_timer <= 0:
			if character.velocity.y > 100:
				character.velocity.y /= 2
			if character.velocity.y > 0:
				character.velocity.y -= boost_power
			else:
				character.velocity.y -= boost_power/2
	boost_cooldown_timer = 0.45
	old_gravity_scale = character.gravity_scale
	character.gravity_scale = gravity_scale

func _update(_delta):
	var sprite = character.sprite
	sprite.speed_scale = 1 + (attack_timer*2)
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
	return spin_timer == 0

func _general_update(delta):
	if boost_cooldown_timer > 0:
		boost_cooldown_timer -= delta
		if boost_cooldown_timer <= 0:
			boost_cooldown_timer = 0
	if spin_disable_time > 0:
		spin_disable_time -= delta
		if spin_disable_time <= 0:
			spin_disable_time = 0
	if spin_timer > 0:
		spin_timer -= delta
		if spin_timer <= 0:
			spin_timer = 0 if !character.inputs[4][0] else 0.05
	if character.inputs[4][0] and spin_timer == 0.0 and spin_disable_time == 0:
		spin_timer = 0.2
	if character.inputs[4][1]:
		sound_buffer = 0.2
	if character.is_grounded():
		spin_disable_time = 0
	
	if attack_timer > 0:
		attack_timer -= delta
		if attack_timer <= 0:
			attack_timer = 0
			character.spin_area_shape.disabled = true
	
	if sound_buffer > 0:
		sound_buffer -= delta
		if sound_buffer <= 0:
			sound_buffer = 0
