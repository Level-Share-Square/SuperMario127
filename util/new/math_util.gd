class_name math_util

static func scalar_color_division(scalar: float, color: Color, divide_alpha: bool = false):
	return Color(scalar/color.r, scalar/color.g, scalar/color.b, scalar/color.a if divide_alpha else color.a)

