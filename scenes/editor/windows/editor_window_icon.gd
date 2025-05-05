tool
extends TextureRect


export var pop_size: float = 2

var texture_scale: Vector2


func _process(delta):
	texture_scale = texture.get_size()/rect_size
	
	material.set_shader_param("width", min(texture_scale.x * pop_size, texture_scale.y * pop_size))
