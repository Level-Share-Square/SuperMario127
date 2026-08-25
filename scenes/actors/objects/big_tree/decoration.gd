class_name Decoration
extends GameObject

export var custom_preview_position = Vector2(70, 170)
export(Array, Texture) var palette_textures
export var zero_is_default: bool = false

func _ready():
	preview_position = custom_preview_position
	var _connect = connect("property_changed", self, "update_property")
	update_property("palette", palette)

func update_property(key: String, value):
	if key == "palette":
		if zero_is_default:
			$Sprite.texture = palette_textures[value]
		elif value != 0:
			$Sprite.texture = palette_textures[value - 1]
