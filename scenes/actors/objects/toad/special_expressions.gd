extends AnimatedSprite

onready var spots = $Spots

func _process(delta):
	if not is_instance_valid(spots): return
	
	offset = Vector2.ZERO
	rotation_degrees = 0
	
	if animation == "confused":
		rotation_degrees = 10
		offset = Vector2(1, 0)
	
	if animation == "raging":
		modulate = lerp(modulate, Color.red, delta)
		offset = Vector2(
			rand_range(-1.0, 1.0),
			rand_range(0, 2.0)
		)
	else:
		modulate = lerp(modulate, Color.white, delta * 4)
	
	spots.offset = offset
	
