extends State

class_name LavaBoostState

export var boost_velocity = 650
export var bounce_velocity = 140
export var extra_velocity = 80
var bounces_left = 0
var burn_cooldown = 0.0
var burn_sound_cooldown = 0.0

func _ready():
	priority = 5
	auto_flip = true
	override_rotation = true

func _start_check(_delta):
	return (character.lava_detector.get_overlapping_areas().size() > 0 and character.terrain_detector.get_overlapping_bodies().size() == 0) and !(character.powerup != null and character.powerup.id == 0)
	
func _start(_delta):
	character.sprite.rotation_degrees = 0
	character.current_jump = 0
	character.friction = 4
	var multiply = -1
	var lava = character.lava_detector.get_overlapping_areas()[0].get_parent()
	
	var threshold = -999
	if stepify(lava.rotation_degrees, 10) == 0:
		threshold = lava.position.y + (lava.height - 16)
	elif stepify(lava.rotation_degrees, 10) == 180:
		threshold = lava.position.y - 16
	
	if character.position.y > threshold:
		multiply = 0.5
	character.velocity.y = boost_velocity * multiply
	bounces_left = 3
	priority = 5
	character.burn_particles.emitting = true
	
	if burn_sound_cooldown <= 0:
		character.sound_player.play_burn_sound()
		burn_sound_cooldown = 0.15
	
	if burn_cooldown <= 0:
		character.damage(3, "lava", 0)
		if character.health > 0:
			character.sound_player.play_lava_hurt_sound()
		burn_cooldown = 1
		

func _update(delta):
	var sprite = character.sprite
	sprite.animation = "lavaBoost"
	
	var offset_x = (randi() % 2) - 1
	var offset_y = (randi() % 2) - 1
	sprite.offset = Vector2(offset_x, offset_y)
	
	character.burn_particles.position.x = -2.5 * character.facing_direction

	if character.is_grounded() and bounces_left > 0:
		character.velocity.y = -(bounce_velocity + (extra_velocity * bounces_left))
		bounces_left -= 1
	
	if _start_check(delta):
		_start(delta)

func _stop(delta):
	character.burn_particles.emitting = false
	var sprite = character.sprite
	sprite.offset.y = 0
	character.friction = character.real_friction
	character.set_state_by_name("BounceState", delta)

func _stop_check(_delta):
	return bounces_left <= 0

func _general_update(delta):
	if burn_sound_cooldown > 0:
		burn_sound_cooldown -= delta
		if burn_sound_cooldown <= 0:
			burn_sound_cooldown = 0
	if burn_cooldown > 0:
		burn_cooldown -= delta
		if burn_cooldown <= 0:
			burn_cooldown = 0
