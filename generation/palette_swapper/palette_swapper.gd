extends Control

const PALETTES_PATH: String = "res://generation/palette_swapper/input/palettes/%s.png"
const OUTPUT_PATH: String = "res://generation/palette_swapper/output/textures/%s.png"

export var in_palette: StreamTexture
export(Array, StreamTexture) var in_images
var palette_dict: Dictionary

func get_palette(image: Image, palette_id: int):
	var in_img: Image = in_palette.get_data()
	in_img.convert(Image.FORMAT_RGBA8)
	in_img.lock()
	
	var out_img: Image = load(PALETTES_PATH % palette_id).get_data()
	out_img.lock()
	
	for x in range(in_img.get_width()):
		palette_dict[in_img.get_pixel(x, 0)] = out_img.get_pixel(x, 0)
	
	return paletted_image(image)

func swap_color(color: Color) -> Color:
	if palette_dict.get(color, null) != null:
		return palette_dict.get(color, Color.white)
	return color

func paletted_image(image: Image) -> Image:
	image.convert(Image.FORMAT_RGBA8)
	image.lock()
	
	var img_size: Vector2 = image.get_size()
	for x in range(img_size.x):
		for y in range(img_size.y):
			image.set_pixel(x, y, swap_color(image.get_pixel(x, y)))
	return image

func _ready():
	for image in in_images:
		for palette_id in range(10):
			if level_list_util.file_exists(PALETTES_PATH % palette_id):
				## texture
				var output_image: Image = get_palette(image.get_data(), palette_id)
				var output_name: String = image.resource_path.get_basename().get_file() + "_" + str(palette_id)
				output_image.save_png(OUTPUT_PATH % output_name)
				## done
				print("Palette %s saved successfully as %s." % [palette_id, output_name])
			else:
				break
