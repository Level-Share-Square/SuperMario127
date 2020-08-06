extends State

class_name WallSlideState

export var gravity_scale: float = 0.5
var old_gravity_scale = 1
var wall_buffer = 0.0

var sound_playing = false

func _ready():
	priority = 1

func _start_check(delta):
	return ((character.is_walled_right() and (character.move_direction == 1 or character.is_wj_chained)) or (character.is_walled_left() and (character.move_direction == -1 or character.is_wj_chained))) and !character.is_grounded() and (!character.test_move(character.transform, Vector2(0, 16)) or character.velocity.y < 0 or character.is_wj_chained) and character.jump_animation != 2 and (!character.nozzle or !character.nozzle.activated) and !character.test_move(character.transform, Vector2(0, (character.velocity.y * delta) * 3))

func _start(_delta):
	sound_playing = false
	if character.velocity.y > 0:
		character.velocity.y = character.velocity.y/3
	if character.is_walled_right():
		character.direction_on_stick = 1
	else:
		character.direction_on_stick = -1
	character.velocity.x = character.direction_on_stick * 5
	wall_buffer = 0.075
	old_gravity_scale = character.gravity_scale
	character.gravity_scale = gravity_scale

func _update(delta):
	if character.velocity.y > 0 and !sound_playing:
		sound_playing = true
		character.sound_player.set_skid_playing(true)
		character.particles.emitting = true

	character.velocity.x += character.direction_on_stick * 5
	if !(character.is_walled()):
		wall_buffer -= delta
		if wall_buffer <= 0:
			wall_buffer = 0
		var sprite = character.sprite
		if character.direction_on_stick == 1:
			sprite.animation = "jumpRight"
		else:
			sprite.animation = "jumpLeft"
	else:
		var sprite = character.sprite
		if character.direction_on_stick == 1:
			sprite.animation = "wallSlideRight"
		else:
			sprite.animation = "wallSlideLeft"
		wall_buffer = 0.075
	if character.is_ceiling():
		character.velocity.y = 3
	if character.velocity.y < 0:
		character.gravity_scale = old_gravity_scale
	else:
		character.gravity_scale = gravity_scale

func _stop(_delta):
	character.gravity_scale = old_gravity_scale
	wall_buffer = 0
	character.sound_player.set_skid_playing(false)
	character.particles.emitting = false

func _stop_check(_delta):
	return wall_buffer <= 0 or character.is_grounded()
