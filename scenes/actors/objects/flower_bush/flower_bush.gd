extends GameObject

const EDGE_WIDTH: int = 32
const PART_WIDTH: int = 32
const HEDGE_EDGE_WIDTH: int = 16
const HEDGE_PART_WIDTH: int = 32

onready var sprite: NinePatchRect = $Sprite
onready var recolorable: NinePatchRect = $Sprite/Recolorable

export(Array, Texture) var palette_textures
export(Array, Texture) var flowerless_textures
export(Array, Texture) var recolorable_textures
export(Array, Texture) var hedge_textures

export(Array, Texture) var single_palette_textures
export(Array, Texture) var single_flowerless_textures
export(Array, Texture) var single_recolorable_textures
export(Array, Texture) var single_hedge_textures

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


func _input(event):
	parts_input_handler(event, self)

func update_parts():
	update_property("", null)


