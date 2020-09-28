extends Powerup
class_name WingPowerup

onready var music = get_node("/root/music")

func _ready():
	music_id = 27

func _start(_delta):
	music.play_temporary_music(music_id)

func _stop(_delta):
	music.stop_temporary_music()

func apply_visuals():
	character.metal_particles.emitting = true

func remove_visuals():
	character.metal_particles.emitting = false

func toggle_visuals():
	if character.metal_particles.emitting:
		apply_visuals()
	else:
		remove_visuals()
