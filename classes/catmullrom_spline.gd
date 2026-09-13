class_name CatmullRomSpline

static func sample(points: Array, t: float) -> Vector2:
	if points.size() == 1:
		return points[0]
	if points.size() == 2:
		return points[0].linear_interpolate(points[1], clamp(t, 0.0, 1.0))
	
	var segment_count: int = points.size() - 1
	var scaled_t: float = clamp(t, 0.0, 1.0) * segment_count
	# warning-ignore: narrowing_conversion
	var seg: int = clamp(int(floor(scaled_t)), 0, segment_count - 1)
	var local_t: float = scaled_t - seg
	
	var p0: Vector2 = points[seg - 1] if seg - 1 >= 0 else points[0]
	var p1: Vector2 = points[seg]
	var p2: Vector2 = points[seg + 1]
	var p3: Vector2 = points[seg + 2] if seg + 2 < points.size() else points[points.size() - 1]
	
	return _interpolate(p0, p1, p2, p3, local_t)

static func _interpolate(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> Vector2:
	var t2: float = t * t
	var t3: float = t2 * t
	return 0.5 * (
		(2.0 * p1) +
		(-p0 + p2) * t +
		(2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2 +
		(-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3
	)
