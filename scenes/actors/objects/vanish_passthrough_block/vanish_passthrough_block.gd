extends GameObject

onready var static_body : StaticBody2D = $StaticBody2D
onready var collision_shape : CollisionShape2D = $StaticBody2D/CollisionShape2D

func _ready() -> void:
	if !enabled:
		collision_shape.disabled = true
	elif scale != Vector2.ONE: # Nothing to do on default scale
		# Set inverse scale on the body so its overall scale is identity.
		# For whatever reason, division doesn't work on vectors, soo
		static_body.scale = Vector2(1.0 / scale.x, 1.0 / scale.y)
		# So it doesn't modify all other boxes
		collision_shape.shape = collision_shape.shape.duplicate()
		# Modify the extents by the scale to get the desired collision shape
		collision_shape.shape.extents = Vector2(collision_shape.shape.extents.x * scale.x,\
												collision_shape.shape.extents.y * scale.y)
