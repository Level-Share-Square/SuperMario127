extends State

class_name GetupState

export var get_up_power = 360
export var get_up_power_luigi = 360

func _ready():
	priority = 1
	disable_turning = true
	override_rotation = true
	
func _start(_delta):
	var sprite = character.sprite
	var sound_player = character.get_node("Sounds")
	sound_player.play_dive_sound()
	character.velocity.y = -get_up_power
	character.position.y -= 7
	character.friction = character.real_friction
	sprite.rotation_degrees = 90 * character.facing_direction
	sprite.rotation_degrees = 1
	character.dive_cooldown = 0.15
	character.stamina = 100
	
func _update(delta):
	var sprite = character.sprite
	if abs(sprite.rotation_degrees) < 320 and sprite.rotation_degrees != 0:
		if (character.facing_direction == 1):
			sprite.animation = "tripleJumpRight"
		else:
			sprite.animation = "tripleJumpLeft"
		sprite.rotation_degrees = lerp(abs(sprite.rotation_degrees), 360, 12 * fps_util.PHYSICS_DELTA) * character.facing_direction
	else:
		if (character.facing_direction == 1):
			sprite.animation = "fallRight"
		else:
			sprite.animation = "fallLeft"
		if abs(sprite.rotation_degrees) > 360:
			sprite.rotation_degrees = 0
		else:
			sprite.rotation_degrees = lerp(abs(sprite.rotation_degrees), 360, 12 * fps_util.PHYSICS_DELTA) * character.facing_direction

func _stop(_delta):
	var sprite = character.sprite
	sprite.rotation_degrees = 0

func _stop_check(_delta):
	return character.velocity.y > 0

func _general_update(delta):
	if character.dive_cooldown > 0:
		character.dive_cooldown -= delta
		if character.dive_cooldown <= 0:
			character.dive_cooldown = 0
