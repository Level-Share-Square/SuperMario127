extends Node2D

const MAX_SIZE = 1000000

export var oob_color := Color(0.1, 0.1, 0.1, 0.5)
var limit_rect := get_viewport_rect()

func _draw():
	var x1 = limit_rect.position.x
	var y1 = limit_rect.position.y
	var w = limit_rect.size.x
	var h = limit_rect.size.y
	var x2 = limit_rect.end.x
	var y2 = limit_rect.end.y

	draw_rect(Rect2(-MAX_SIZE, -MAX_SIZE, MAX_SIZE + x1, MAX_SIZE * 2), oob_color)
	draw_rect(Rect2(x2, -MAX_SIZE, MAX_SIZE, MAX_SIZE * 2), oob_color)
	draw_rect(Rect2(x1, -MAX_SIZE, w, MAX_SIZE + y1), oob_color)
	draw_rect(Rect2(x1, y2, w, MAX_SIZE), oob_color)

func set_bounds(new_limits: Rect2):
	limit_rect = new_limits
	update()
