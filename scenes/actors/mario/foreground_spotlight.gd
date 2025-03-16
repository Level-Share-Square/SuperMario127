extends Light2D

var display: bool = false
var target_scale: float = 1.0

func _ready():
	scale = Vector2.ZERO
	visible = false


func _process(delta):
	if display:
		scale = scale.linear_interpolate(Vector2(target_scale, target_scale), interp_weight_idp(7.0, delta))
	else:
		scale = scale.linear_interpolate(Vector2.ZERO, interp_weight_idp(10.0, delta))

	visible = !scale.is_zero_approx()


func interp_weight_idp(weight : float, delta : float) -> float:
	return 1 - exp(-weight * delta)
