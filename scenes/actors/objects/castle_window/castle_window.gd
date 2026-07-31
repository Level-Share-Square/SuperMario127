extends GameObject


export(Array, Texture) var palette_textures


func _ready():
	if palette != 0:
		self.texture = palette_textures[palette - 1]
