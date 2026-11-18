extends RefCounted

static func hits(points: PackedVector2Array, target: Vector2, radius: float) -> bool:
	return not contacts(points, target, radius).is_empty()

static func contacts(points: PackedVector2Array, target: Vector2, radius: float) -> PackedFloat32Array:
	var distances := PackedFloat32Array()
	var traveled := 0.0
	var inside := false
	for i in range(points.size() - 1):
		var offset := points[i] - target
		var segment := points[i + 1] - points[i]
		var length := segment.length()
		if is_zero_approx(length):
			continue
		var projection := offset.dot(segment / length)
		var discriminant := radius * radius - (offset.length_squared() - projection * projection)
		if not inside and discriminant >= 0.0:
			var half_chord := sqrt(discriminant)
			var entry := -projection - half_chord
			var exit := -projection + half_chord
			if entry <= length and exit >= 0.0:
				distances.append(traveled + maxf(entry, 0.0))
		inside = points[i + 1].distance_squared_to(target) <= radius * radius
		traveled += length
	return distances
