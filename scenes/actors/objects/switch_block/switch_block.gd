extends GameObject

onready var static_body : StaticBody2D = $StaticBody2D
onready var collision_shape : CollisionShape2D = $StaticBody2D/CollisionShape2D
onready var sprite : Sprite = $Sprite
onready var p : Sprite = $Sprite/P

var current_scene

var activated = false

func _set_properties():
	savable_properties = ["activated"]
	editable_properties = ["activated"]

func _set_property_values():
	set_property("activated", activated, true)

func _ready() -> void:
	current_scene = get_tree().get_current_scene()
	if scale != Vector2.ONE: # Nothing to do on default scale
		# Set inverse scale on the body so its overall scale is identity.
		# For whatever reason, division doesn't work on vectors, soo
		static_body.scale = Vector2(1.0 / scale.x, 1.0 / scale.y)
		# So it doesn't modify all other boxes
		collision_shape.shape = collision_shape.shape.duplicate()
		# Modify the extents by the scale to get the desired collision shape
		collision_shape.shape.extents = Vector2(collision_shape.shape.extents.x * scale.x,\
												collision_shape.shape.extents.y * scale.y)

func _physics_process(delta):
	if mode == 1 and activated and enabled:
		sprite.modulate = Color(1, 0.5, 0.5)
	elif mode == 1 or !enabled:
		sprite.modulate = Color(1, 1, 1)
		
	p.visible = enabled
	
	if !is_instance_valid(current_scene) or mode == 1 or !enabled: return
	
	var activated_color = Color(1, 1, 1, 1)
	var deactivated_color = Color(1, 1, 1, 0)
	if current_scene.switch_timer > 0:
		if current_scene.switch_timer <= 1.0:
			var alpha = current_scene.switch_timer / 1.0
			if !activated:
				sprite.modulate.a = alpha
			elif current_scene.switch_timer <= 0.5:
				sprite.modulate = lerp(sprite.modulate, activated_color if activated else deactivated_color, delta * 4)
		else:
			sprite.modulate = lerp(sprite.modulate, deactivated_color if activated else activated_color, delta * 4)
		collision_shape.disabled = activated
	else:
		sprite.modulate = activated_color if activated else deactivated_color
		collision_shape.disabled = !activated
