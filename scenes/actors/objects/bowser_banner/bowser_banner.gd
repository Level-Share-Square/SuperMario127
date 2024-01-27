extends GameObject

onready var collision_shape = $StaticBody2D/CollisionShape2D
export var custom_preview_position = Vector2(70, 170)

func _ready():
	collision_shape.disabled = !enabled
	preview_position = custom_preview_position
	if is_preview:
		z_index = 0
		$AnimatedSprite.z_index = 0
	
