extends Resource
class_name LayerState

var order: int
var parallax_distance: float
var tint: Color
var opacity: float
var is_visible: bool
var lock_axis: int

func _init(
	_order: int,
	_parallax_distance: float,
	_tint: Color,
	_opacity: float,
	_is_visible: bool,
	_lock_axis: int
):
	order = _order
	parallax_distance = _parallax_distance
	tint = _tint
	opacity = _opacity
	is_visible = _is_visible
	lock_axis = _lock_axis
