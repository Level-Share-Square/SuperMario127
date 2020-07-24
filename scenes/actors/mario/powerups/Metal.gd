extends Powerup
class_name MetalPowerup

func _ready():
	music_id = 25

func _start(_delta):
	character.metal_voice = true

func _stop(_delta):
	character.metal_voice = false

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
