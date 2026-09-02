class_name ToxicGas
extends LiquidBase

export var toxicity : float = 0.0

func get_liquid_properties() -> Array:
	return ["toxicity"]
	
func _register_property_info():
	._register_property_info()
	set_property_info("toxicity", PropertyInfo.new("Drains health from the player at a rate of approximately this/6.5s\nIf this is above 255, this will instantly kill the player.", 1, -INF, INF, ["", ""], ["", ""], false, "Toxicity"))


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

	update_liquid_color(color)
	z_index = -1 if !render_in_front else 1024 #Same as BackBufferCopy z-index to prevent transparency issues
	
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
	liquid_area_collision.disabled = !is_enabled_and_on_ground()
	
	update_liquid_color(color)
	update()
