extends LiquidBase

onready var threshold_gradient : TextureRect = $ThresholdGradient

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
		"size" or "death_threshold":
			if key == "death_threshold":
				update_death_threshold(value)
			else:
				update_death_threshold(death_threshold)


func update_liquid_color(color):
	waves.material.set_shader_param("color", color)
	liquid_body.material.set_shader_param("color", color)

func update_death_threshold(threshold):
	threshold_gradient.rect_size = size
	var gradient_position = max(threshold, 16)/size.y
	print(gradient_position)
	var gradient : GradientTexture2D = threshold_gradient.texture
	gradient.fill_from.y = (gradient_position - 18/size.y)
	print(gradient.fill_from.y)
	gradient.fill_to.y = (gradient_position + 6/size.y)
	print(gradient.fill_to.y)

func _ready():
	if mode == 1:
		connect("property_changed", self, "update_property")
	
	liquid_area.monitoring = enabled
	liquid_area.monitorable = enabled
	liquid_type = LiquidType.Quicksand
	
	waves.material.set_shader_param("x_size", waves.rect_size.x)
	waves.material.set_shader_param("noise_scale_1", waves.rect_size/Vector2(512, 512))
	waves.material.set_shader_param("noise_scale_2", waves.rect_size/Vector2(32, 32))
	waves.material.set_shader_param("noise_scale_3", waves.rect_size/Vector2(128, 128))
	
	liquid_body.material.set_shader_param("noise_scale_1", liquid_body.rect_size/Vector2(512, 512))
	liquid_body.material.set_shader_param("noise_scale_2", liquid_body.rect_size/Vector2(32, 32))
	liquid_body.material.set_shader_param("noise_scale_3", liquid_body.rect_size/Vector2(128, 128))
	
	update_liquid_color(color)
	

func _physics_process(delta):
	update_death_threshold(death_threshold)
	if !enabled: return
	
	for body in liquid_area.get_overlapping_bodies():
		if body.name.begins_with("Character"):
			var character : Character = body
			if character.velocity.y > sinking_speed:
				character.velocity.y -= 80*delta*60
			else:
				character.velocity.y = sinking_speed
				if character.state == character.get_state_node("GroundPoundState"):
					character.set_state_by_name("FallState")
					
			character.velocity.x /= 2.5
			
			if body.global_position.y > global_position.y + death_threshold:
				body.kill("quicksand")
