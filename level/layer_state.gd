extends Resource
class_name LayerState

var order: int
var parallax_distance: float
var tint: Color
var opacity: float

func _init(
	_order: int,
	_parallax_distance: float,
	_tint: Color,
	_opacity: float
):
	order = _order
	parallax_distance = _parallax_distance
	tint = _tint
	opacity = _opacity
