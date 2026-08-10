extends Powerup
class_name WingPowerup

onready var music = Singleton.Music
var last_flying: bool

func _ready():
	music_id = 27

func _start(_delta, play_temp_music: bool):
	start_display_timer()
	emit_signal("powerup_state_changed", id)
	if play_temp_music:
		Singleton.Music.play_temporary_music(music_id)
	Singleton.Music.toggle_blended_music(character.state is WingMarioState)

func _stop(_delta):
	emit_signal("powerup_state_changed", "Normal")
	Singleton.Music.stop_temporary_music()
	Singleton.Music.toggle_blended_music(false)

func _update(_delta):
	var flying: bool = character.state is WingMarioState
	if (flying and not last_flying) or (not flying and last_flying):
		Singleton.Music.toggle_blended_music(flying)
	last_flying = flying

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
