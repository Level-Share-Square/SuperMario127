extends Control

const PALETTES_PATH: String = "res://generation/autotiles/input/palettes/%s.png"
const OUTPUT_PATH: String = "res://generation/autotiles/output/textures/%s.png"
const OUTPUT_ICON_FULL_PATH: String = "res://generation/autotiles/output/icons/full_%s.png"
const OUTPUT_ICON_LEFT_PATH: String = "res://generation/autotiles/output/icons/slope_left_%s.png"
const OUTPUT_ICON_RIGHT_PATH: String = "res://generation/autotiles/output/icons/slope_right_%s.png"
const OUTPUT_ICON_HALF_PATH: String = "res://generation/autotiles/output/icons/half_%s.png"

onready var viewport = $"%Viewport"
export var in_palette: StreamTexture
var base_image: Image
var palette_dict: Dictionary

func get_palette(palette_id: int):
	var in_img: Image = in_palette.get_data()
	in_img.convert(Image.FORMAT_RGBA8)
	in_img.lock()
	
	var out_img: Image = load(PALETTES_PATH % palette_id).get_data()
	out_img.lock()
	
	for x in range(in_img.get_width()):
		palette_dict[in_img.get_pixel(x, 0)] = out_img.get_pixel(x, 0)
	
	return paletted_image()

func swap_color(color: Color) -> Color:
	if palette_dict.get(color, null) != null:
		return palette_dict.get(color, Color.white)
	return color

func paletted_image() -> Image:
	var image: Image = base_image.duplicate()
	image.convert(Image.FORMAT_RGBA8)
	image.lock()
	
	var img_size: Vector2 = image.get_size()
	for x in range(img_size.x):
		for y in range(img_size.y):
			image.set_pixel(x, y, swap_color(image.get_pixel(x, y)))
	return image

func _ready():
	for i in range(5):
		yield(get_tree(), "idle_frame")
	
	base_image = viewport.get_texture().get_data()
	base_image.convert(Image.FORMAT_RGBA8)
	
	for palette_id in range(10):
		if level_list_util.file_exists(PALETTES_PATH % palette_id):
			## texture
			var image: Image = get_palette(palette_id)
			image.flip_y()
			image.save_png(OUTPUT_PATH % palette_id)
			## icons
			var icon_full_image: Image = image.duplicate().get_rect(Rect2(0, 96, 32, 32))
			icon_full_image.save_png(OUTPUT_ICON_FULL_PATH % palette_id)
			var icon_left_image: Image = image.duplicate().get_rect(Rect2(544, 96, 32, 32))
			icon_left_image.save_png(OUTPUT_ICON_LEFT_PATH % palette_id)
			var icon_right_image: Image = image.duplicate().get_rect(Rect2(0, 256, 32, 32))
			icon_right_image.save_png(OUTPUT_ICON_RIGHT_PATH % palette_id)
			var icon_half_image: Image = image.duplicate().get_rect(Rect2(544, 256, 32, 32))
			icon_half_image.save_png(OUTPUT_ICON_HALF_PATH % palette_id)
			## done
			print("Palette %s saved successfully." % palette_id)
		else:
			break
