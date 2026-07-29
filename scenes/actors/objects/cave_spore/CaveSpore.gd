extends GameObject

export(Array, Texture) var palette_textures

func _ready():
	if is_preview:
		z_index = 0
		$Sprite.z_index = 0

	if palette != 0:
		$Sprite.texture = palette_textures[palette - 1]

func _object_disabled_ready():
	._object_disabled_ready()
	$StaticBody2D/CollisionShape2D.disabled = !enabled
