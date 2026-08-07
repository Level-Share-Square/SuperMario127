tool
extends Control


func _draw() -> void:
	draw_line(Vector2(8, rect_size.y + 8), Vector2(rect_size.x + 8, 8), Color(0, 0, 0, 0.5), 18)
	draw_line(Vector2(1, rect_size.y + 1), Vector2(rect_size.x + 1, 1), Color(1, 1, 1, 0.8), 2)
