extends GameObject

func _ready():
	$StaticBody2D/CollisionShape2D.disabled = !enabled
