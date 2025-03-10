class_name Decoration
extends GameObject

export var custom_preview_position = Vector2(70, 170)
export(Array, Texture) var palette_textures

func _ready():
	preview_position = custom_preview_position
	if is_preview:
		z_index = 0
		$Sprite.z_index = 0
	
	if palette != 0:
		$Sprite.texture = palette_textures[palette - 1]
