extends LiquidBase

onready var threshold_gradient : TextureRect = $ThresholdGradient
onready var bubbles : Particles2D = $Bubbles

var sinking_speed : float = 30.0
var death_threshold : float = 128.0

func get_liquid_properties():
	return [
		"sinking_speed",
		"death_threshold",
	]

func update_property(key, value):
	match(key):
		"color":
			update_liquid_color(value)
		"size":
			update()
		"death_threshold":
			update()
				


func update_liquid_color(color):
	waves.material.set_shader_param("color", color)
	liquid_body.material.set_shader_param("color", color)

func update():
	threshold_gradient = get_node("ThresholdGradient")
	threshold_gradient.rect_size = size
	var gradient_position = max(death_threshold, 18)/size.y
	var gradient : GradientTexture2D = threshold_gradient.texture
	gradient.fill_from.y = 0
	gradient.fill_to.y = (gradient_position + 6/size.y)
	
	if death_threshold <= 2:
		bubbles.visible = true
		bubbles.position = size/2
		bubbles.process_material.emission_box_extents = Vector3(bubbles.position.x, bubbles.position.y, 0)
	else:
		bubbles.visible = false
	
	#update shader stuff
	waves.material.set_shader_param("x_size", waves.rect_size.x)
	waves.material.set_shader_param("noise_scale_1", waves.rect_size/Vector2(512, 512))
	waves.material.set_shader_param("noise_scale_2", waves.rect_size/Vector2(32, 32))
	waves.material.set_shader_param("noise_scale_3", waves.rect_size/Vector2(128, 128))
	
	liquid_body.material.set_shader_param("noise_scale_1", liquid_body.rect_size/Vector2(512, 512))
	liquid_body.material.set_shader_param("noise_scale_2", liquid_body.rect_size/Vector2(32, 32))
	liquid_body.material.set_shader_param("noise_scale_3", liquid_body.rect_size/Vector2(128, 128))
	

func _ready():
	if mode == 1:
		connect("property_changed", self, "update_property")
	else:
		connect("transform_changed", self, "update")
	
	liquid_area.monitoring = (enabled and mode != 1)
	liquid_area.monitorable = (enabled and mode != 1)
	
	update_liquid_color(color)
	update()
	

func _physics_process(delta):
	if size != last_size:
		update()
