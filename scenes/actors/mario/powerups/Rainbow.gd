extends Powerup
class_name RainbowPowerup

var hue = 0

func _ready():
	is_invincible = true
	music_id = 25

func _start(delta):
	character.set_state_by_name("RainbowStarState", delta)

func _stop(delta):
	pass

func _update(delta):
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

func remove_visuals():
	character.sprite.material = null

func toggle_visuals():
	if character.sprite.material == null:
		apply_visuals()
	else:
		remove_visuals()
