extends Button
## Moldura de lápis sobre o papel original, sem cantos arredondados de UI moderna.

var draw_outline := true

func _draw() -> void:
	if not draw_outline:
		return
	var ink := Color(0.13, 0.12, 0.10, 0.35 if disabled else 0.90)
	var points := PackedVector2Array()
	var corners := [Vector2(2, 3), Vector2(size.x - 3, 2), Vector2(size.x - 2, size.y - 3), Vector2(3, size.y - 2)]
	for side in range(4):
		var a: Vector2 = corners[side]
		var b: Vector2 = corners[(side + 1) % 4]
		var normal := a.direction_to(b).orthogonal()
		for i in range(12):
			var t := float(i) / 12.0
			points.append(a.lerp(b, t) + normal * sin(t * 21 + side) * 0.7)
	points.append(points[0])
	draw_polyline(points, ink, 1.5, true)
