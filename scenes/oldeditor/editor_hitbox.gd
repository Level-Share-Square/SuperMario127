extends Area2D
class_name EditorHitbox


func is_in_point(point: Vector2) -> bool:
	for polygon in get_children():
		if Geometry.is_point_in_polygon(point, polygon.get_global_transform().xform(polygon.get_polygon())):
			return true
	
	return false
