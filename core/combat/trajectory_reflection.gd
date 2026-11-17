extends RefCounted

const MAX_BOUNCES := 16
const CONTACT_EPSILON := 0.01

static func reflect_path(points: PackedVector2Array, mirrors: Array) -> PackedVector2Array:
	if points.size() < 2 or mirrors.is_empty():
		return points
	var result := PackedVector2Array([points[0]])
	var basis := Transform2D.IDENTITY
	var cursor := points[0]
	var bounces := 0
	for i in range(1, points.size()):
		var remaining := basis.basis_xform(points[i] - points[i - 1])
		while remaining.length() > CONTACT_EPSILON:
			var fraction := INF
			var normal := Vector2.ZERO
			for mirror: PackedVector2Array in mirrors:
				var tangent := mirror[1] - mirror[0]
				var hit := _intersection_fraction(cursor, remaining, mirror[0], tangent)
				if hit < fraction:
					fraction = hit
					normal = tangent.orthogonal().normalized()
			if fraction == INF:
				cursor += remaining
				result.append(cursor)
				break
			cursor += remaining * fraction
			result.append(cursor)
			bounces += 1
			if bounces >= MAX_BOUNCES:
				return result
			basis.x = basis.x.bounce(normal)
			basis.y = basis.y.bounce(normal)
			remaining = (remaining * (1.0 - fraction)).bounce(normal)
	return result

static func _intersection_fraction(start: Vector2, delta: Vector2, mirror_start: Vector2, tangent: Vector2) -> float:
	var determinant := delta.cross(tangent)
	if is_zero_approx(determinant):
		return INF
	var offset := mirror_start - start
	var t := offset.cross(tangent) / determinant
	var u := offset.cross(delta) / determinant
	if t * delta.length() <= CONTACT_EPSILON or t > 1.0 or u < 0.0 or u > 1.0:
		return INF
	return t
