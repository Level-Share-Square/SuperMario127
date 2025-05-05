extends OptionButton


const ICON_SCALE_FACTOR: float = 1.0

export var icon_count: int = 1
export var textures: Texture

var icons: Array = []


func _ready():
	for i in range(0, icon_count):
		var new_image := AtlasTexture.new()
		new_image.set_atlas(textures)
		new_image.region.size = Vector2(32, 32) * ICON_SCALE_FACTOR
		new_image.region.position.x = i * 32 * ICON_SCALE_FACTOR
		icons.append(new_image)
		
		add_icon_item(icons[i], "", i)
