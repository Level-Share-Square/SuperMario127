extends Powerup
class_name MetalPowerup

onready var music = Singleton.Music
var last_active = false

func _ready():
	music_id = 25
	time_left = 3

func _start(_delta, play_temp_music: bool):
	start_display_timer()
	emit_signal("powerup_state_changed", id)
	character.metal_voice = true
	if play_temp_music:
		Singleton.Music.play_temporary_music(music_id)

func _stop(_delta):
	stop_display_timer()
	emit_signal("powerup_state_changed", "Normal")
	character.metal_voice = false
	Singleton.Music.stop_temporary_music()

func _process(_delta):
	if character.powerup == self:
		if !last_active:
			for raycast in character.raycasts:
				raycast.set_collision_mask_bit(8, true)
		character.set_collision_mask_bit(8, true)
		character.breath = 100
	else:
		if last_active:
			for raycast in character.raycasts:
				raycast.set_collision_mask_bit(8, false)
		character.set_collision_mask_bit(8, false)
	if character.sprite.material == material:
		var bevel_offset := Vector2(1, 2).rotated(-character.sprite.rotation)
		character.sprite.material.set_shader_param("bevel_offset", bevel_offset)
	
	last_active = (character.powerup == self)

func apply_visuals():
	character.sprite.material = material
	character.metal_particles.emitting = true
	if character.lava_detector.get_overlapping_bodies().size() == 0:
		character.set_collision_mask_bit(8, true)

func remove_visuals():
	character.sprite.material = null
	character.metal_particles.emitting = false

func toggle_visuals():
	if character.sprite.material == null:
		apply_visuals()
	else:
		remove_visuals()
