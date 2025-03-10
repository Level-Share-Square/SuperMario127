extends LiquidBase

onready var threshold_gradient : TextureRect = $ThresholdGradient
onready var bubbles : Particles2D = $InstaKillBubbles

var sinking_speed : float = 30.0
var death_threshold : float = 128.0

func get_liquid_properties():
	return [
		"sinking_speed",
		"death_threshold",
	]

func update_property(key, value):
	update()
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
	waves.rect_position.y = surface_offset
	waves.rect_size.x = size.x
	if waves_enable:
		waves.visible = true
		liquid_body.rect_position.y = waves.rect_position.y+waves.rect_size.y
		liquid_body.rect_size = size-liquid_body.rect_position
		threshold_gradient.rect_position = Vector2(0, 8)
		threshold_gradient.rect_size = Vector2(liquid_body.rect_size.x, liquid_body.rect_size.y+16)
	else:
		waves.visible = false
		liquid_body.rect_position.y = 0
		liquid_body.rect_size = size
		threshold_gradient.rect_position = liquid_body.rect_position
		threshold_gradient.rect_size = size
	
	var gradient_position = max(death_threshold, 18)/size.y
	var gradient : GradientTexture2D = threshold_gradient.texture
	gradient.fill_from.y = 0
	gradient.fill_to.y = (gradient_position+6/size.y)
	
	if death_threshold <= 0:
		bubbles.visible = true
		bubbles.visibility_rect.position = Vector2.ZERO
		bubbles.visibility_rect.size = Vector2(size.x-4, size.y)
		bubbles.position = size/2
		bubbles.position.y += 10
		bubbles.process_material.emission_box_extents = Vector3(size.x/2, (size.y-10)/2, 0)
		bubbles.modulate = color
		bubbles.process_material.color.a8 = 60
		bubbles.amount = (size.x*size.y)/(64*64)
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
	update_liquid_color(color)
	update()
	

func _physics_process(delta):
	if size != last_size:
		update()
