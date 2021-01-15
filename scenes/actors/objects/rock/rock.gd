extends GameObject

export var custom_preview_position = Vector2(70, 170)

func _ready():
	preview_position = custom_preview_position
	if is_preview:
		z_index = 0
		$Sprite.z_index = 0
	if !enabled:
		$StaticBody2D.set_collision_layer_bit(0, false)