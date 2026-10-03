class_name line_util


static func get_line(start: Vector2, end: Vector2) -> PoolVector2Array:
	var points: PoolVector2Array = []
	var steps: float = (end - start).length()
	if steps == 0: return [end] as PoolVector2Array
	
	# adding one, so it doesr't stop drawing too early
	for step in range(steps + 1):
		var time: float = step / steps
		var current_point: Vector2 = lerp(Vector2(start), Vector2(end), time).round()
		if points.empty() or points[points.size() - 1] != current_point:
			points.append(current_point)
	
	points.append(end)
	return points
