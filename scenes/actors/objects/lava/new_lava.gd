class_name Lava
extends LiquidBase

onready var new = $New
onready var lava_light = $New/Waves/LavaLight
onready var bubbles = $New/Waves/Bubbles

onready var body_collision = $StaticBody2D/CollisionShape2D

onready var old = $Old
onready var old_waves = $Old/Waves
onready var old_waves_recolorable = $Old/Waves/WavesRecolorable
onready var old_lava_fill = $Old/Body

var use_old_lava: bool = false
var lighting: bool = true
var surface_color: Color = Color8(255, 195, 0, 255)

var surface_gradient : GradientTexture = GradientTexture.new()


func get_liquid_properties():
	return [
		"use_old_lava",
		"lighting",
		"surface_color"
	]
	
func _register_property_info():
	._register_property_info()
	set_property_info("use_old_lava", PropertyInfo.new("Uses the pre 0.10 lava texture", 1, -INF, INF, ["", ""], ["", ""], false, "Use Old Lava"))
	set_property_info("lighting", PropertyInfo.new("Light is emitted from the lava's surface", 1, -INF, INF, ["", ""], ["", ""], false, "Lighting"))
	set_property_info("surface_color", PropertyInfo.new("The color of the lava's surface.", 1, -INF, INF, ["", ""], ["", ""], false, "Surface Color"))


func update_property(key, value):
	.update_property(key, value)
	visual = $New if !use_old_lava else $Old
	match(key):
		"color" or "surface_color":
			update_liquid_color(value)
		"render_in_front":
			z_index = -1 if !value else 1024 #Same as layer BackBufferCopy z-index to prevent transparency issues
	update()


func update_liquid_color(color):
	waves.material.set_shader_param("color", surface_color)
	var rounded_surface_color = Color(stepify(surface_color.r, 0.05), stepify(surface_color.g, 0.05), stepify(surface_color.b, 0.05))
	var gradient = Gradient.new()
	gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CUBIC
	gradient.colors = PoolColorArray(
		[
			color if color == Color(1, 0, 0) else surface_color.s/1.1,
			surface_color,
			Color.white
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
		waves.material.set_shader_param("position", global_position)
		waves.material.set_shader_param("size", waves.rect_size)
		waves.material.set_shader_param("offset", Vector2(position.x, 0))
	else:
		waves.visible = false
	z_index = -1 if !render_in_front else 1024 #Same as layer BackBufferCopy z-index to prevent transparency issues

	#update new stuff
	liquid_body.rect_position.y = 0
	liquid_body.rect_size = size
	liquid_body.material.set_shader_param("position", global_position)
	liquid_body.material.set_shader_param("size", liquid_body.rect_size)
	liquid_body.material.set_shader_param("offset", position)
	liquid_body.material.set_shader_param("rotation", rotation)
	
	lava_light.rect_size.x = size.x
	lava_light.material.set_shader_param("noise_scale", Vector2(size.x/256, .25))
	lava_light.visible = lighting
	lava_light.color = color.linear_interpolate(surface_color, 0.5)
	
	bubbles.position.x = size.x/2
	bubbles.process_material.emission_box_extents.x = (size.x/2) - 4
	bubbles.amount = int(size.x/14)
	bubbles.visibility_rect.position.x = -size.x/2
	bubbles.visibility_rect.size.x = size.x
	bubbles.modulate = color.linear_interpolate(surface_color, 0.75)
#	bubbles.modulate.a = 0.43
	
	#update old stuff
	body_collision.position = liquid_area_collision.position
	body_collision.shape = liquid_area_collision.shape
	
	if waves_enable:
		old_waves.visible = true
		old_waves.rect_size.x = old_lava_fill.rect_size.x
		old_waves_recolorable.rect_size.x = old_lava_fill.rect_size.x
		old_waves.material.set_shader_param("size", liquid_body.rect_size)
		old_waves.material.set_shader_param("offset", Vector2(position.x, 0))
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
	visual = $New if !use_old_lava else $Old
	
	change_size()

	update_liquid_color(color)
	update()

func _object_ready():
	._object_ready()
	liquid_area.monitoring = is_enabled_and_on_ground()
	liquid_area.monitorable = is_enabled_and_on_ground()


func _editor_ready() -> void:
	var scene = get_tree().current_scene
	if scene.placed_item_property == "NewLava":
		set_property("use_old_lava", false)
	
	_object_ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _object_process(_delta):
	._object_process(_delta)
	
	if (new.visible == use_old_lava):
		new.visible = !use_old_lava
		old.visible = use_old_lava


func update_light_layer():
	lava_light.range_z_max = z_index - 1
	lava_light.range_z_min = lava_light.range_z_max - (LevelShared.layer_spacing * 1.5)
