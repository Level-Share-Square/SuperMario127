extends Powerup
class_name WingPowerup

onready var music = Singleton.Music
var last_grounded: bool

func _ready():
	music_id = 27

func _start(_delta, play_temp_music: bool):
	start_display_timer()
	emit_signal("powerup_state_changed", id)
	if play_temp_music:
		Singleton.Music.play_temporary_music(music_id)
	Singleton.Music.toggle_blended_music(not character.is_grounded())

func _stop(_delta):
	emit_signal("powerup_state_changed", "Normal")
	Singleton.Music.stop_temporary_music()
	Singleton.Music.toggle_blended_music(false)

func _update(_delta):
	var grounded: bool = character.is_grounded()
	if (grounded and not last_grounded) or (not grounded and last_grounded):
		Singleton.Music.toggle_blended_music(not grounded)
	last_grounded = grounded

func apply_visuals():
	character.metal_particles.emitting = true
	character.wing_sprite.visible = true

func remove_visuals():
	character.metal_particles.emitting = false
	character.wing_sprite.visible = false

func toggle_visuals():
	if character.metal_particles.emitting:
		remove_visuals()
	else:
		apply_visuals()
