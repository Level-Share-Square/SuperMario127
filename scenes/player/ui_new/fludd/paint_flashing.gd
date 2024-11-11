extends Polygon2D

export var default_color: Color
export var animated_color: Gradient

export var flash_speed: float
export var is_flashing: bool
var color_offset: float

func _physics_process(delta):
	color = color.linear_interpolate(default_color, delta * flash_speed)
	if not is_flashing: return
	
	color_offset = wrapf(color_offset + (delta * flash_speed), 0, 1)
	color = animated_color.interpolate(color_offset)
