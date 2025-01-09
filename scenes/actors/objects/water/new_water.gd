extends LiquidBase

export var toxicity : float = 0.0

func get_liquid_properties() -> Array:
	return ["toxicity"]

func update_property(key, value):
	update()

func update():
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
