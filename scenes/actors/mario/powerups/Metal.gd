extends Powerup
class_name MetalPowerup

onready var music = get_node("/root/music")
func _ready():
	music_id = 25
	time_left = 3

func _start(_delta):
	character.metal_voice = true
	music.play_temporary_music(music_id)

func _stop(_delta):
	character.metal_voice = false
	music.stop_temporary_music()

func apply_visuals():
	character.sprite.material = material
	character.metal_particles.emitting = true

func remove_visuals():
	character.sprite.material = null
	character.metal_particles.emitting = false

func toggle_visuals():
	if character.sprite.material == null:
		apply_visuals()
	else:
		remove_visuals()
