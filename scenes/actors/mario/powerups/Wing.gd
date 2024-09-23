extends Powerup
class_name WingPowerup

onready var music = Singleton.Music

func _ready():
	music_id = 27

func _start(_delta, play_temp_music: bool):
	start_display_timer()
	emit_signal("powerup_state_changed", id)
	if play_temp_music:
		Singleton.Music.play_temporary_music(music_id)

func _stop(_delta):
	stop_display_timer()
	emit_signal("powerup_state_changed", "Normal")
	Singleton.Music.stop_temporary_music()

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
