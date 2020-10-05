extends GameObject

func _ready() -> void:
	if !enabled:
		$StaticBody2D/CollisionShape2D.disabled = true
