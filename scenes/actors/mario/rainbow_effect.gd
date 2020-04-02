extends AnimatedSprite

var hue = 0

func _process(delta):
	hue += 0.035
	var gradient_texture = GradientTexture.new()
	var gradient = Gradient.new()
	gradient.offsets = PoolRealArray([0.15, 1])
	gradient.colors = PoolColorArray([Color.from_hsv(hue, 1, 1), Color(1, 1, 1)])
	gradient_texture.gradient = gradient
	material.set_shader_param("gradient", gradient_texture)
