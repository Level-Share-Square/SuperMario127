class_name PaletteButton
extends ButtonHoverVertical

const PALETTES_PATH: String = "res://scenes/actors/mario/palettes/%s/%s.png"
const CHAR_NAMES: Array = ["Mario", "Luigi"]

export var base_texture: StreamTexture
export var in_palette: StreamTexture
export var palette_id: String

var in_img: Image 
var out_img: Image

var stored_textures: Array
var character: int

func load_palette(new_character: int):
	character = new_character
	$Orb.texture = stored_textures[character]

func get_palette(char_name: String):
	in_img = in_palette.get_data()
	out_img = load(PALETTES_PATH % [char_name.to_lower(), palette_id]).get_data()
	in_img.lock()
	out_img.lock()
	return paletted_image()

func swap_color(color: Color) -> Color:
	for x in range(in_img.get_width()):
		var color_in: Color = in_img.get_pixel(x, 0)
		if color.is_equal_approx(color_in):
			return out_img.get_pixel(x, 0)
	return color

func paletted_image() -> ImageTexture:
	var image: Image = base_texture.get_data()
	var img_size: Vector2 = image.get_size()
	image.lock()
	for x in range(img_size.x):
		for y in range(img_size.y):
			image.set_pixel(x, y, swap_color(image.get_pixel(x, y)))
	
	var texture := ImageTexture.new()
	texture.create_from_image(image, 1)
	return texture

func _ready():
	toggled(pressed)
	for char_name in CHAR_NAMES:
		stored_textures.append(get_palette(char_name))
	load_palette(character)

func toggled(button_pressed: bool):
	$Outline.region_rect.position.x = 16 if button_pressed else 0
