extends GameObject

export(Array, Texture) var palette_textures

func _ready():
	if is_preview:
		z_index = -1
		$Sprite.z_index = -1
	
	if palette != 0:
		$Sprite.texture = palette_textures[palette - 1]
