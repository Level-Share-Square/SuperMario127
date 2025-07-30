extends Node


## Only exported so the animation player can set this.
export var get_outta_here: bool = false

onready var ap: AnimationPlayer = get_node("%AnimationPlayer")

var state: int = 1


func _input(event):
	if event is InputEventMouseMotion or event is InputEventJoypadMotion:
		return

	match state:
		1:
			ap.stop()

			var disclaimer: Label = get_node("%Disclaimer")
			var indicator: Label = get_node("%Indicator")

			while disclaimer.modulate.a != 0:
				disclaimer.modulate.a = lerp_fr(disclaimer.modulate.a, 0, 0.1, 0.1)
				indicator.modulate.a = lerp_fr(indicator.modulate.a, 0, 0.1, 0.1)
				yield(get_tree(), "idle_frame")

			state = 2
			ap.play("presents")
		2:
			ap.stop()

			while owner.modulate != Color.black:
				owner.modulate = lerp_colr(owner.modulate, Color.black, 0.1, 0.1)
				yield(get_tree(), "idle_frame")

			get_outta_here = true


## Acts like a lerp but skips to the end value if [code]end - start < diff[/code].
func lerp_fr(start: float, end: float, incr: float, diff: float):
	if abs(end - start) < diff:
		if incr >= 0: return end
		if incr < 0: return start
	return start + (end - start)*incr
	
	
	## Lerp function for colors, includes the functionality of [method lerpfr].
func lerp_colr(col_start: Color, col_end: Color, incr: float, diff: float):
	if _dist_color(col_start, col_end) < diff:
		if incr >= 0: return col_end
		if incr < 0: return col_start
	return col_start + (col_end-col_start)*incr
#endregion


func _dist_color(col_start: Color, col_end: Color):
	var r = col_start.r - col_end.r
	var g = col_start.g - col_end.g
	var b = col_start.b - col_end.b
	var a = col_start.a - col_end.a

	return sqrt(r*r + g*g + b*b + a*a)
