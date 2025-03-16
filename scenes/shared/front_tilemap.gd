extends TileMap


var display = false


func _process(delta):
	if self_modulate == Color.white:
		if display:
			modulate = modulate.linear_interpolate(Color8(0, 0, 0, 64), interp_weight_idp(7.0, delta))
		else:
			modulate = modulate.linear_interpolate(Color.white, interp_weight_idp(10.0, delta))
	else:
		modulate = self_modulate
		
	display = false


func interp_weight_idp(weight : float, delta : float) -> float:
	return 1 - exp(-weight * delta)
