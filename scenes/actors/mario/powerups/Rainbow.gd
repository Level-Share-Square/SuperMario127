extends Powerup
class_name RainbowPowerup

var hue = 0
var rainbow_trails = []
var trail_timer = 0.075

onready var trail_script = load("res://scenes/actors/mario/powerups/rainbow_trail.gd")

func _ready():
	is_invincible = true
	music_id = 26

func _start(delta):
	pass

func _stop(delta):
	pass

func create_trail():
	var trail = character.sprite.duplicate()
	trail.global_position = character.sprite.global_position
	trail.playing = false
	trail.z_index = -2
	trail.script = trail_script
	add_child(trail)

func _update(delta):
	trail_timer -= delta
	if trail_timer <= 0:
		trail_timer = 0.075
		create_trail()
		
	if character.state != character.get_state_node("RainbowStarState"):
		character.set_state_by_name("RainbowStarState", delta)
	if character.sprite.material != null:
		hue += 0.015
		var gradient_texture = GradientTexture.new()
		var gradient = Gradient.new()
		gradient.offsets = PoolRealArray([0.15, 1])
		gradient.colors = PoolColorArray([Color.from_hsv(hue, 1, 1), Color(1, 1, 1)])
		gradient_texture.gradient = gradient
		character.sprite.material.set_shader_param("gradient", gradient_texture)

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
