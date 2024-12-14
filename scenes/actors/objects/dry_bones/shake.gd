extends AnimatedSprite


export var shake_amount: float


func _process(delta):
	if is_zero_approx(shake_amount): 
		offset = Vector2.ZERO
		return
	offset.x = rand_range(-1.0, 1.0) * shake_amount
	offset.y = rand_range(-1.0, 1.0) * shake_amount
