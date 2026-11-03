extends Control
## Traços calculados sobre o background original; nenhuma imagem de mapa pronto.

var buttons: Dictionary = {}
var rows: Array = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	queue_redraw.call_deferred()

func _draw() -> void:
	for row in rows:
		for node in row:
			if not buttons.has(node.id):
				continue
			var rect: Rect2 = buttons[node.id].get_global_rect()
			var center := get_global_transform().affine_inverse() * rect.get_center()
			for id in node.next:
				if not buttons.has(id):
					continue
				var next_rect: Rect2 = buttons[id].get_global_rect()
				var finish := get_global_transform().affine_inverse() * next_rect.get_center()
				var direction := center.direction_to(finish)
				var start := center + direction * 45
				var end := finish - direction * 45
				var active: bool = GameManager.visited_nodes.has(node.id) and (GameManager.available_nodes.has(id) or GameManager.visited_nodes.has(id))
				_draw_path(start, end, int(node.seed) + id.hash(), active)
			if GameManager.available_nodes.has(node.id):
				_draw_pencil_ring(center, 49.0, int(node.seed))
			if GameManager.visited_nodes.has(node.id):
				var tick := center + Vector2(30, -36)
				draw_polyline(PackedVector2Array([tick + Vector2(-8, 0), tick, tick + Vector2(12, -16)]), Color("52664e"), 3, true)

func _draw_path(start: Vector2, end: Vector2, path_seed: int, active: bool) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = path_seed
	var normal := start.direction_to(end).orthogonal()
	var bend := (start + end) * 0.5 + normal * rng.randf_range(-22, 22)
	var points := PackedVector2Array()
	var steps := maxi(int(start.distance_to(end) / 4), 16)
	for i in range(steps + 1):
		var t := float(i) / steps
		var p := start.lerp(bend, t).lerp(bend.lerp(end, t), t)
		p += normal * sin(t * 17.0 + float(path_seed % 11)) * 1.4
		points.append(p)
	var ink := Color(0.12, 0.12, 0.10, 0.90 if active else 0.38)
	for i in range(points.size() - 1):
		if active or i % 5 < 3:
			draw_line(points[i], points[i + 1], ink, 2.3 if active else 1.5, true)

func _draw_pencil_ring(center: Vector2, radius: float, ring_seed: int) -> void:
	var points := PackedVector2Array()
	for i in range(57):
		var angle := float(i) / 56.0 * TAU
		var r := radius + sin(angle * 5 + float(ring_seed % 9)) * 1.6
		points.append(center + Vector2(cos(angle), sin(angle)) * r)
	draw_polyline(points, Color("3a3931"), 1.8, true)
