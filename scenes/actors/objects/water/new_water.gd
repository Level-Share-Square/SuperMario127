extends LiquidBase

export var toxicity : float = 0.0

func get_liquid_properties() -> Array:
	return ["toxicity"]

func update_property(key, value):
	update()

func update():
	waves.rect_position.y = surface_offset
	waves.rect_size.x = size.x
	if waves_enable:
		waves.visible = true
		liquid_body.rect_position.y = waves.rect_position.y+waves.rect_size.y
		liquid_body.rect_size = size-liquid_body.rect_position
	else:
		waves.visible = false
		liquid_body.rect_position.y = 0
		liquid_body.rect_size = size
	
	waves.get_material().set_shader_param("color_tint", color)
	waves.get_material().set_shader_param("x_size", size.x)
	liquid_body.get_material().set_shader_param("color_tint", color)

func _ready():
	if mode == 1:
		connect("property_changed", self, "update_property")
	else:
		connect("transform_changed", self, "update")
	
	liquid_area_collision.disabled = !enabled
	
	update_liquid_color(color)
	update()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
