class_name Decoration
extends GameObject

export var custom_preview_position = Vector2(70, 170)
export(Array, Texture) var palette_textures

func _ready():
	._ready()
	
	preview_position = custom_preview_position
	
	if palette != 0:
		$Sprite.texture = palette_textures[palette - 1]
