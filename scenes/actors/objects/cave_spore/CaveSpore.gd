extends GameObject

func _ready():
	if is_preview:
		z_index = 0
		$Sprite.z_index = 0
	$StaticBody2D/CollisionShape2D.disabled = !enabled
