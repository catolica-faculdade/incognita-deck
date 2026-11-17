extends RefCounted

const MAX_BOUNCES := 16
const CONTACT_EPSILON := 0.01

static func reflect_path(points: PackedVector2Array, mirrors: Array) -> PackedVector2Array:
	return trace(points, mirrors, []).points

static func trace(points: PackedVector2Array, mirrors: Array, barriers: Array) -> Dictionary:
	if points.size() < 2 or (mirrors.is_empty() and barriers.is_empty()):
		return {"points": points, "reflected": false}
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
			var blocked := false
			for barrier: PackedVector2Array in barriers:
				var hit := _intersection_fraction(cursor, remaining, barrier[0], barrier[1] - barrier[0])
				if hit != INF and hit <= fraction:
					fraction = hit
					blocked = true
			if fraction == INF:
				cursor += remaining
				result.append(cursor)
				break
			cursor += remaining * fraction
			result.append(cursor)
			if blocked:
				return {"points": result, "reflected": bounces > 0}
			bounces += 1
			if bounces >= MAX_BOUNCES:
				return {"points": result, "reflected": true}
			basis.x = basis.x.bounce(normal)
			basis.y = basis.y.bounce(normal)
			remaining = (remaining * (1.0 - fraction)).bounce(normal)
	return {"points": result, "reflected": bounces > 0}

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
