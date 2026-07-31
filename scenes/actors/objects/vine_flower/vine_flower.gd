extends GameObject

export var custom_preview_position = Vector2(70, 170)
onready var collision_shape = $StaticBody2D/CollisionShape2D
export(Array, Texture) var palette_textures

var color := Color(1, 0, 0)


func _register_properties():
	register_property(4, "color", color)

func _ready():
	collision_shape.disabled = !is_enabled_and_on_ground()
	preview_position = custom_preview_position
	if is_preview:
		z_index = 0
		$Sprite.z_index = 0
		
	if palette != 0:
		$Sprite.texture = palette_textures[palette - 1]

func _process(delta):
	if color == Color(1, 0, 0):
		$Color.visible = false
	else:
		$Color.visible = true
		$Color.modulate = color
