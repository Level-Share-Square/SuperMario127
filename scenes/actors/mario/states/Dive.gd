extends State

class_name DiveState

export var dive_power : Vector2 = Vector2(1200, 75)
export var dive_power_luigi : Vector2 = Vector2(1200, 75)
export var bonk_power : float = 150
export var maxVelocityX : float = 700
var sound_player
var last_above_rot_limit := false
var dive_buffer := 0.0
var start_facing := 1
var speed_cooldown := 0.0

func _ready() -> void:
	priority = 3
	attack_tier = 1
	disable_turning = true
	blacklisted_states = ["SlideState", "GetupState"]
	override_rotation = true
	use_dive_collision = true

# this is the worst thing i've ever seen in my life
func _start_check(_delta : float) -> bool:
	return dive_buffer > 0 and character.dive_cooldown <= 0 and !(abs(character.velocity.x) <= 150 and character.is_grounded()) and !character.test_move(character.transform, Vector2(8 * character.facing_direction, 0)) and !character.is_walled()

func _start(_delta : float) -> void:
	start_facing = character.facing_direction
	var sound_player : Node = character.sound_player # Sounds is apparently a node that gets added at runtime??
	if dive_buffer > 0 and character.dive_cooldown == 0:
		if character.character == 0:
			character.velocity.x = character.velocity.x - (character.velocity.x - (dive_power.x * character.facing_direction)) / 5
			character.velocity.y += dive_power.y
		else:
			character.velocity.x = character.velocity.x - (character.velocity.x - (dive_power_luigi.x * \
					character.facing_direction)) / 5
			character.velocity.y += dive_power_luigi.y
		sound_player.play_dive_sound()
	character.position.y += 4
	character.rotating = true
	character.ground_shape.disabled = true
	if abs(character.velocity.x) > maxVelocityX:
		character.velocity.x = maxVelocityX * character.facing_direction
	character.jump_animation = 0
	character.current_jump = 0
	character.dive_cooldown = 0.15

func _update(_delta) -> void:
	var sprite : AnimatedSprite = character.sprite
	if (!character.is_grounded()):
		character.friction = character.real_friction
	if (character.facing_direction == 1):
		sprite.animation = "diveRight"
	else:
		sprite.animation = "diveLeft"
	var new_angle : float = (character.velocity.y / 15) + 90
	if (abs(new_angle) < 185):
		sprite.rotation_degrees = lerp(abs(sprite.rotation_degrees), new_angle, 20 * fps_util.PHYSICS_DELTA) * character.facing_direction
		last_above_rot_limit = false
	else:
		if (!last_above_rot_limit):
			sprite.rotation_degrees = 185 * character.facing_direction
		sprite.rotation_degrees += 0.15 * character.facing_direction
		last_above_rot_limit = true

func _stop(delta : float) -> void:
	var sprite : AnimatedSprite = character.sprite
	if !character.test_move(character.transform, Vector2(0, 8)) and character.test_move(character.transform, Vector2(0.1 * character.facing_direction, -15)) and !character.test_move(character.transform, Vector2(0, -16)) and !character.is_grounded():
		character.velocity.x = bonk_power * -character.facing_direction
		character.velocity.y = -65
		character.position.x -= 2 * character.facing_direction
		character.position.y -= 16
		character.set_state_by_name("BonkedState", delta)
		character.sound_player.play_bonk_sound()
		sprite.rotation_degrees = 0
	if character.is_on_wall():
		character.velocity.x = 150 * -character.facing_direction
		character.velocity.y = -65
		character.position.x -= 2 * character.facing_direction
		character.set_state_by_name("BonkedState", delta)
		character.sound_player.play_bonk_sound()
	if character.is_grounded():
		character.set_state_by_name("SlideState", delta)
	elif !character.check_liquid(LiquidBase.LiquidType.Water):
		sprite.rotation_degrees = 0
	character.ground_shape.disabled = true
	
	if character.is_grounded() or character.check_liquid(LiquidBase.LiquidType.Quicksand):
		character.facing_direction = start_facing
		var normal = character.ground_check.get_collision_normal()
		var sprite_rotation = atan2(normal.y, normal.x) + (PI/2)
		sprite_rotation += PI/2 * start_facing
		character.sprite.rotation = sprite_rotation
		#below fixes an issue with dives putting your bottom position below the actual surface of the liquid
		if character.check_liquid(LiquidBase.LiquidType.Quicksand) or character.check_liquid(LiquidBase.LiquidType.Lava):
			character.global_position.y -= 12

func _stop_check(_delta : float) -> bool:
	return character.is_grounded() or (character.is_walled_right() and character.facing_direction == 1) or (character.is_walled_left() and character.facing_direction == -1)

func _general_update(delta : float) -> void:
	if character.inputs[3][1] and character.dive_cooldown == 0:
		dive_buffer = 0.075
	if dive_buffer > 0:
		dive_buffer -= delta
		if dive_buffer < 0:
			dive_buffer = 0
	if speed_cooldown > 0:
		speed_cooldown -= delta
		if speed_cooldown < 0:
			speed_cooldown = 0
	character.ground_shape.disabled = true
