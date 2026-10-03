extends TextureRect

func _ready():
	material.set_shader_param("gradient", Singleton.MiscShared.rainbow_gradient_texture)
