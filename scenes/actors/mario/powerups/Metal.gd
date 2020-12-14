extends Powerup
class_name MetalPowerup

onready var music = get_node("/root/music")
func _ready():
	music_id = 25
	time_left = 3

func _start(_delta, play_temp_music: bool):
	character.metal_voice = true
	if play_temp_music:
		music.play_temporary_music(music_id)

func _stop(_delta):
	character.metal_voice = false
	music.stop_temporary_music()

func _process(_delta):
	if character.sprite.material == material:
		var bevel_offset := Vector2(1, 2).rotated(-character.sprite.rotation)
		character.sprite.material.set_shader_param("bevel_offset", bevel_offset)

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
