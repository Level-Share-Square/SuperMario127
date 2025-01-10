extends LiquidBase

onready var new = $New
onready var lava_light = $New/Waves/LavaLight
onready var bubbles = $New/Waves/Bubbles

onready var body_collision = $StaticBody2D/CollisionShape2D

onready var old = $Old
onready var old_waves = $Old/Waves
onready var old_waves_recolorable = $Old/Waves/WavesRecolorable
onready var old_lava_fill = $Old/Body

var use_old_lava : bool = true
var lighting : bool = true
var surface_color : Color = Color8(255, 195, 0, 255)

var surface_gradient : GradientTexture = GradientTexture.new()

func get_liquid_properties():
	return [
		"use_old_lava",
		"lighting",
		"surface_color"
	]

func update_property(key, value):
	update()
	match(key):
		"color":
			update_liquid_color(value)
		"surface_color":
			update_liquid_color(color)

func update_liquid_color(color):
	waves.material.set_shader_param("color", surface_color)
	
	var gradient = Gradient.new()
	gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CUBIC
	gradient.colors = PoolColorArray(
		[
			color if color == Color(1, 0, 0) and surface_color == Color8(255, 195, 0) else surface_color.s/1.1,
			surface_color,
			Color(1, 1, 1, 1)
		]
	)
	gradient.offsets = PoolRealArray(
		[
			0,
			0.75,
			1
		]
	)
	
	surface_gradient.gradient = gradient
	waves.material.set_shader_param("noise_texture_1", surface_gradient)
	
	liquid_body.material.set_shader_param("color", color)
	lava_light.material.set_shader_param("color", color)
	bubbles.modulate = Color(surface_color.r, surface_color.g, surface_color.b, 111)
	
	#update old color
	var rounded_color = Color(stepify(color.r, 0.05), stepify(color.g, 0.05), stepify(color.b, 0.05))
	if rounded_color == Color(0.5, 0, 0) or rounded_color == Color(1, 0, 0):
		old_waves_recolorable.visible = false
		old_lava_fill.color = Color(0.431373, 0, 0.14902)
		old_lava_fill.modulate = Color(1, 1, 1)
		old_waves.self_modulate = Color(1, 1, 1)
	else:
		old_waves_recolorable.visible = true
		old_waves_recolorable.modulate = color
		old_lava_fill.color = Color(0.282353, 0.282353, 0.282353)
		old_lava_fill.modulate = color
		var desat_color = color
		desat_color.s /= 2
		old_waves.self_modulate = desat_color

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
	waves.material.set_shader_param("x_size", waves.rect_size.x)
	waves.material.set_shader_param("noise_scale_2", waves.rect_size/Vector2(64, 64))
	waves.material.set_shader_param("noise_scale_3", waves.rect_size/Vector2(512, 512))
	
	liquid_body.material.set_shader_param("noise_scale_1", liquid_body.rect_size/Vector2(64, 64))
	liquid_body.material.set_shader_param("noise_scale_2", liquid_body.rect_size/Vector2(64, 64))
	liquid_body.material.set_shader_param("noise_scale_3", liquid_body.rect_size/Vector2(512, 512))
	
	lava_light.visible = lighting
	lava_light.rect_size.x = size.x
	lava_light.material.set_shader_param("noise_scale", Vector2(size.x/256, .25))
	
	bubbles.position.x = size.x/2
	bubbles.process_material.emission_box_extents.x = (size.x/2) - 4
	bubbles.amount = int(size.x/14)
	bubbles.visibility_rect.position.x = -size.x/2
	bubbles.visibility_rect.size.x = size.x
	
	#update old stuff
	body_collision.position = liquid_area_collision.position
	body_collision.shape = liquid_area_collision.shape
	
	if waves_enable:
		old_waves.visible = true
		old_waves.rect_size.x = old_lava_fill.rect_size.x
		old_waves_recolorable.rect_size.x = old_lava_fill.rect_size.x
		old_lava_fill.rect_position.y = old_waves.rect_position.y+old_waves.rect_size.y
		old_lava_fill.rect_size = size-old_lava_fill.rect_position
	else:
		old_waves.visible = false
		old_lava_fill.rect_position.y = 0
		old_lava_fill.rect_size = size


# Called when the node enters the scene tree for the first time.
func _ready():
	#gets the correct nodes for the waves and liquid body
	waves = $New/Waves
	liquid_body = $New/Body
	
	var scene = get_tree().current_scene
	if scene.mode == 1 and scene.placed_item_property == "NewLava":
		set_property("use_old_lava", false)
	
	change_size()
	
	if mode == 1:
		connect("property_changed", self, "update_property")
	else:
		connect("transform_changed", self, "update")
	
	
	liquid_area.monitoring = (enabled and mode != 1)
	liquid_area.monitorable = (enabled and mode != 1)
	
	update_liquid_color(color)
	update()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (new.visible == use_old_lava):
		new.visible = !use_old_lava
		old.visible = use_old_lava
