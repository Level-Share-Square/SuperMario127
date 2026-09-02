class_name Quicksand
extends LiquidBase

enum DepthResults {Surface, Sinking, Death}

onready var threshold_gradient : TextureRect = $Visual/ThresholdGradient
onready var bubbles : Particles2D = $Visual/InstaKillBubbles

var sinking_speed : float = 30.0
var death_threshold : float = 128.0

## Box which determines where mario will slow down to a crawl when walking
var sink_rect := Rect2(Vector2(0, death_threshold), size)

## Box which determines where mario will die
var death_rect := Rect2(Vector2(0, death_threshold), size)

func get_liquid_properties():
	return [
		"sinking_speed",
		"death_threshold",
	]
	
func _register_property_info():
	._register_property_info()
	set_property_info("sinking_speed", PropertyInfo.new("The speed at which the player sinks in this quicksand.", 1, -INF, INF, ["", ""], ["", ""], false, "Sinking Speed"))
	set_property_info("death_threshold", PropertyInfo.new("How far beneath the surface the player can go before dying\nIf this is 0, the surface will bubble, indicating instant death.", 1, 0, INF, ["", ""], ["", ""], false, "Death Threshold"))


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
	sink_rect.position = Vector2(0, 2)
	sink_rect.size = size
	
	death_rect.position = Vector2(0, death_threshold)
	death_rect.size = size
	
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
	update_liquid_color(color)
	z_index = -1 if !render_in_front else 1024 #Same as layer BackBufferCopy z-index to prevent transparency issues

	var gradient_position = max(death_threshold, 18)/size.y
	var gradient : GradientTexture2D = threshold_gradient.texture
	gradient.fill_from.y = 0
	gradient.fill_to.y = (gradient_position+6/size.y)
	
	if death_threshold <= 0:
		bubbles.visible = true
		bubbles.position = Vector2(size.x/2, 0)
		bubbles.process_material.emission_box_extents.x = (size.x/2) - 4
		bubbles.amount = int(size.x/22)
		bubbles.visibility_rect.position.x = -size.x/2
		bubbles.visibility_rect.size.x = size.x
		bubbles.modulate = color
		bubbles.modulate.s /= 1.5
		bubbles.modulate.a = 1
	else:
		bubbles.visible = false
	
	#update shader stuff
	liquid_body.material.set_shader_param("position", Vector2.ZERO)
	liquid_body.material.set_shader_param("size", liquid_body.rect_size)
	liquid_body.material.set_shader_param("rotation", rotation)
	liquid_body.material.set_shader_param("offset", -position)
	
	waves.material.set_shader_param("position", Vector2(0, 32))
	waves.material.set_shader_param("size", waves.rect_size)
	waves.material.set_shader_param("rotation", rotation)
	waves.material.set_shader_param("offset", -position)


func _ready():
	update()
	update_liquid_color(color)


func _physics_process(delta):
	if size != last_size:
		update()


func depth_check(pos: Vector2):
	var local_pos : Vector2 = to_local(pos)
	
	if death_rect.has_point(local_pos):
		return DepthResults.Death
	elif sink_rect.has_point(local_pos):
		return DepthResults.Sinking
	else:
		return DepthResults.Surface

func is_middle(check: bool):
	.is_middle(check)
	
	$LiquidArea/CollisionShape2D.disabled = !check
