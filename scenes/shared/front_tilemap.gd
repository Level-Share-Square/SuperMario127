extends TileMap


var display = false
var target_alpha = 1.0


func _process(delta):
	if display and target_alpha == 1.0:
		modulate = modulate.linear_interpolate(Color(0, 0, 0, 0.25), interp_weight_idp(7.0, delta))
	else:
		modulate = modulate.linear_interpolate(Color(1, 1, 1, target_alpha), interp_weight_idp(10.0, delta))
		
	display = false


func interp_weight_idp(weight : float, delta : float) -> float:
	return 1 - exp(-weight * delta)
