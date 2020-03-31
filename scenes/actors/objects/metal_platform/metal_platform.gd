extends GameObject

func _ready():
	$StaticBody2D/CollisionShape2D.disabled = !enabled
	preview_position = Vector2(0, 92)
