extends Powerup 
class_name VanishPowerup 

func _ready():
	music_id = 29
	set_physics_process(false)

func _start(_delta, play_temp_music: bool):
	if play_temp_music:
		music.play_temporary_music(music_id)
	character.set_all_collision_masks(6, false)

func _stop(_delta):
	music.stop_temporary_music()
	character.set_all_collision_masks(6, true)
	#if the player is colliding with a 0,0 velocity, that means they are inside a vanish cap passthrough block
	if character.test_move(character.transform, Vector2(0,0)):
		#disable collisions with the passthrough blocks again, and then enable physics process so we can check for this till it's time to disable vanish cap
		character.set_all_collision_masks(6, false)
		set_physics_process(true)
	
#checking this every physics frame could be slow, if it's a problem a timer may be necessary
func _physics_process(_delta):
	character.set_all_collision_masks(6, true)
	#if the player is colliding with a 0,0 velocity, that means they are inside a vanish cap passthrough block
	if character.test_move(character.transform, Vector2(0,0)):
		#disable collisions with the passthrough blocks again
		character.set_all_collision_masks(6, false)
	else:
		#no collisions, so leave collisions enabled and disable physics process
		set_physics_process(false)

func apply_visuals():
	character.sprite.material = material 
	character.vanish_particles.emitting = true

func remove_visuals():
	character.sprite.material = null 
	character.vanish_particles.emitting = false

func toggle_visuals():
	if character.sprite.material == null:
		apply_visuals()
	else:
		remove_visuals()
