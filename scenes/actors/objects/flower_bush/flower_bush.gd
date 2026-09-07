extends GameObject

const EDGE_WIDTH: int = 32
const PART_WIDTH: int = 64
const HEDGE_EDGE_WIDTH: int = 16
const HEDGE_PART_WIDTH: int = 32

onready var sprite: NinePatchRect = $Sprite
onready var recolorable: NinePatchRect = $Sprite/Recolorable
onready var interaction_area = $Area2D
onready var interaction_shape = $Area2D/CollisionShape2D

export(Array, Texture) var palette_textures
export(Array, Texture) var flowerless_textures
export(Array, Texture) var recolorable_textures
export(Array, Texture) var hedge_textures

export(Array, Texture) var single_palette_textures
export(Array, Texture) var single_flowerless_textures
export(Array, Texture) var single_recolorable_textures
export(Array, Texture) var single_hedge_textures

var displacement : float = 0.0
var displacement_spring_anim_power : float = 0.0

var base_scale_factor : float = 0.0
var scale_spring_anim_power : float = 0.0

var flowers: bool = true
var flower_color: Color = Color.yellow
var parts: int = 1
var hedge: bool = false


func _register_properties():
	register_property(4, "flowers", flowers, true)
	register_property(5, "flower_color", flower_color, true)
	register_property(6, "parts", parts, true)
	register_property(7, "hedge", hedge, true)


func _ready():
	interaction_shape.shape = interaction_shape.shape.duplicate()
	interaction_area.connect("body_entered", self, "start_anim")

	var _connect = connect("property_changed", self, "update_property")
	update_property("palette", palette)
	update_property("parts", parts)


func update_property(key: String, value):
	recolorable.modulate = flower_color
	recolorable.visible = flowers and not hedge and (flower_color != Color.yellow)
	
	var palette_tex: Array = palette_textures if parts > 1 else single_palette_textures
	var flowerless_tex: Array = flowerless_textures if parts > 1 else single_flowerless_textures
	var recolorable_tex: Array = recolorable_textures if parts > 1 else single_recolorable_textures
	if hedge:
		palette_tex = hedge_textures if parts > 1 else single_hedge_textures
		flowerless_tex = palette_tex
	
	sprite.texture = palette_tex[palette] if flowers else flowerless_tex[palette]
	recolorable.texture = recolorable_tex[palette]
	
	var edge_width: int = HEDGE_EDGE_WIDTH if hedge else EDGE_WIDTH
	var part_width: int = HEDGE_PART_WIDTH if hedge else PART_WIDTH
	
	sprite.patch_margin_left = edge_width
	sprite.patch_margin_right = edge_width
	
	sprite.rect_size.x = edge_width*2 + part_width * (parts - 1)
	sprite.rect_position.x = -sprite.rect_size.x / 2
	sprite.rect_pivot_offset = -sprite.rect_position
	sprite.rect_pivot_offset.y *= 2
	editor_rect = Rect2(sprite.rect_position, sprite.rect_size)
	interaction_shape.shape.extents.x = (sprite.rect_size.x / 2) - 12


func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and is_object_hovered():
		if event.button_index == 5: # Mouse wheel down
			parts -= 1
			if parts < 1:
				parts = 1
			set_property("parts", parts)
		elif event.button_index == 4: # Mouse wheel up
			parts += 1
			set_property("parts", parts)


func _object_process(delta: float) -> void:
	if !is_equal_approx(displacement_spring_anim_power, 0):
		update_displacement_spring(delta)
	else:
		sprite.material.set_shader_param("strength", 0)
	
	if !is_equal_approx(scale_spring_anim_power, 0):
		update_scale_spring(delta)
	else:
		sprite.rect_scale = Vector2.ONE


func start_anim(body):
	var entrance_velocity := Vector2.ZERO
	
	if "velocity" in body:
		entrance_velocity = body.velocity
	elif "velocity" in body.get_parent():
		entrance_velocity = body.get_parent().velocity
	
	if sign(entrance_velocity.x) == 0:
		set_scale_spring(8)
	else:
#		set_scale_spring(-7)
		set_displacement_spring(10 * sign(entrance_velocity.x))


func set_displacement_spring(power : float):
	displacement_spring_anim_power = power

func update_displacement_spring(delta):
	var spring_constant = 200
	var damping_constant = 12
	
	var damping_ratio = damping_constant / (2 * sqrt(spring_constant))

	
	var force = (-spring_constant * displacement) + (damping_constant * displacement_spring_anim_power)
	displacement_spring_anim_power -= force * delta
	displacement -= displacement_spring_anim_power * delta
	
	sprite.material.set_shader_param("strength", displacement)


func set_scale_spring(power : float):
	scale_spring_anim_power = power

func update_scale_spring(delta):
	var spring_constant = 200
	var damping_constant = 20
	
	var damping_ratio = damping_constant / (2 * sqrt(spring_constant))
	
	var force = (-spring_constant * base_scale_factor) + (damping_constant * scale_spring_anim_power)
	scale_spring_anim_power -= force * delta
	base_scale_factor -= scale_spring_anim_power * delta
	
	sprite.rect_scale.y = (1 + base_scale_factor)
	sprite.rect_scale.x = 1-((sprite.rect_scale.y-1)/2)
