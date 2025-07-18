class_name ToxicGas
extends LiquidBase

export var toxicity : float = 0.0

func get_liquid_properties() -> Array:
	return ["toxicity"]

func update_property(key, value):
	update()

func update():
	#update base stuff
	if waves_enable:
		waves.visible = true
		waves.rect_size.x = size.x
		liquid_body.rect_position.y = 0
		liquid_body.rect_size = size
	else:
		waves.visible = false
		liquid_body.rect_position.y = 0
		liquid_body.rect_size = size
	
	#update new stuff
	waves.material.set_shader_param("position", global_position)
	waves.material.set_shader_param("size", waves.rect_size)
	waves.material.set_shader_param("offset", Vector2(position.x, 0))
	
	liquid_body.material.set_shader_param("position", global_position)
	liquid_body.material.set_shader_param("size", liquid_body.rect_size)
	liquid_body.material.set_shader_param("offset", position)
	liquid_body.material.set_shader_param("rotation", rotation)

	waves.get_material().set_shader_param("color_tint", color)
	waves.get_material().set_shader_param("x_size", size.x)
	liquid_body.get_material().set_shader_param("color_tint", color)
	pass

func _ready():
	liquid_area_collision.disabled = !enabled
	
	update_liquid_color(color)
	update()
