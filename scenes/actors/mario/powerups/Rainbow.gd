extends Powerup
class_name RainbowPowerup

var hue = 0
var rainbow_trails = []
var trail_timer = 0.075
var has_landed = false

onready var trail_script = load("res://scenes/actors/mario/powerups/rainbow_trail.gd")

func _ready():
	is_invincible = true
	music_id = 26

func _start(_delta):
	music.play_temporary_music(music_id)
	has_landed = false
	character.set_nozzle("null", true) # Disable FLUDD, it's unusable anyway

func _stop(_delta):
	music.stop_temporary_music()

func create_trail():
	var trail = character.sprite.duplicate()
	trail.global_position = character.sprite.global_position
	trail.playing = false
	trail.z_index = -2
	trail.script = trail_script
	add_child(trail)

func _process(delta):
	if character.sprite.material == material:
		hue += 0.015
		var gradient_texture = GradientTexture.new()
		var gradient = Gradient.new()
		gradient.offsets = PoolRealArray([0.15, 1])
		gradient.colors = PoolColorArray([Color.from_hsv(hue, 1, 1), Color(1, 1, 1)])
		gradient_texture.gradient = gradient
		character.sprite.material.set_shader_param("gradient", gradient_texture)

func _update(delta):
	if !has_landed: #and character.is_grounded():
		has_landed = true
	if has_landed and character.state != character.get_state_node("RainbowStarState"):
		character.velocity.x *= 1.5
		character.set_state_by_name("RainbowStarState", delta)
	
	trail_timer -= delta
	if trail_timer <= 0:
		trail_timer = 0.075
		create_trail()

func apply_visuals():
	character.sprite.material = material
	character.rainbow_particles.emitting = true

func remove_visuals():
	character.sprite.material = null
	character.rainbow_particles.emitting = false

func toggle_visuals():
	if character.sprite.material == null:
		apply_visuals()
	else:
		remove_visuals()
