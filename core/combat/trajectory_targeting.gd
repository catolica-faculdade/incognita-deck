extends RefCounted

static func hits(points: PackedVector2Array, target: Vector2, radius: float) -> bool:
	for i in range(points.size() - 1):
		var closest := Geometry2D.get_closest_point_to_segment(target, points[i], points[i + 1])
		if closest.distance_to(target) <= radius:
			return true
	return false
