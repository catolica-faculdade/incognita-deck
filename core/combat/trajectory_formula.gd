extends RefCounted
## Composição matemática do protótipo sem depender de UI ou SceneTree.

var displacement := Vector2.ZERO
var a := 0.0
var b := 0.0
var c := 0.0
var wave_enabled := false
var amplitude := 0.0
var frequency := 0.0
var wave_length := 0.0
var wave_components: Array = []
var path_operations: Array[Dictionary] = []
var has_cards := false

func rebuild(cards: Array) -> void:
	displacement = Vector2.ZERO
	a = 0.0
	b = 0.0
	c = 0.0
	wave_enabled = false
	amplitude = 0.0
	frequency = 0.0
	wave_length = 0.0
	wave_components.clear()
	path_operations.clear()
	has_cards = false
	for card in cards:
		if card.get("type", "") not in ["effect", "reflection"]:
			has_cards = true
		match card.get("type", "linear"):
			"linear", "diagonal":
				displacement += Vector2(float(card.get("x", 0)), float(card.get("y", 0)))
			"quadratic":
				match card.get("coefficient", ""):
					"a": a += float(card.get("value", 0))
					"b": b += float(card.get("value", 0))
					"c": c += float(card.get("value", 0))
			"special":
				if card.get("special_type", "") == "wave":
					wave_enabled = true
					amplitude += float(card.get("amplitude", 2.0))
					frequency += float(card.get("frequency", 2.0))
					wave_length = maxf(wave_length, float(card.get("length", 8.0)))
					wave_components.append({"amplitude": float(card.get("amplitude", 2.0)), "frequency": float(card.get("frequency", 2.0)), "length": maxf(float(card.get("length", 8.0)), 0.01)})
			"spiral", "reflection":
				path_operations.append(card)

func has_quadratic() -> bool:
	return a != 0.0 or b != 0.0 or c != 0.0

func end_x() -> float:
	if wave_enabled:
		return maxf(displacement.x, wave_length)
	if displacement.x > 0.0:
		return displacement.x
	return 8.0 if has_quadratic() else displacement.x

func sample(grid_unit: float = 75.0, resolution: int = 40) -> PackedVector2Array:
	if not has_cards:
		return PackedVector2Array([Vector2.ZERO])
	var result := _sample_base(grid_unit, resolution)
	for operation in path_operations:
		match operation.type:
			"spiral":
				var center := result[-1]
				var steps := int(operation.turns) * 32
				for i in range(1, steps + 1):
					var fraction := float(i) / steps
					var angle := fraction * TAU * float(operation.turns)
					var direction := Vector2(cos(angle), -sin(angle))
					result.append(center + direction * (fraction * float(operation.radius) * grid_unit))
			"reflection":
				for i in range(result.size()):
					result[i] = Vector2(result[i].x, -result[i].y)
	return result

func _sample_base(grid_unit: float, resolution: int) -> PackedVector2Array:
	if not has_quadratic() and not wave_enabled:
		if displacement.is_zero_approx():
			return PackedVector2Array([Vector2.ZERO])
		return PackedVector2Array([Vector2.ZERO, displacement * Vector2(grid_unit, -grid_unit)])
	var result := PackedVector2Array()
	var steps := maxi(resolution, 1)
	for i in range(steps + 1):
		var t := float(i) / steps
		var x := t * end_x()
		var y := a * x * x + b * x + c + displacement.y
		for wave in wave_components:
			y += sin(x * TAU * float(wave.frequency) / float(wave.length)) * float(wave.amplitude)
		result.append(Vector2(x * grid_unit, -y * grid_unit))
	return result

func equation_text() -> String:
	if not has_cards:
		return "y = 0"
	var text := _base_equation_text()
	for operation in path_operations:
		var label := "Espiral (%d voltas)" % operation.turns if operation.type == "spiral" else "Reflexão em X"
		text += (" → " if not text.is_empty() else "") + label
	return text

func _base_equation_text() -> String:
	if not has_quadratic() and not wave_enabled:
		if displacement.is_zero_approx() and not path_operations.is_empty():
			return ""
		return "(0, 0) → (%.1f, %.1f)" % [displacement.x, displacement.y]
	var text := "y = %.2fx² + %.2fx + %.2f" % [a, b, c + displacement.y]
	for wave in wave_components:
		text += " + %.1f sen(2π · %.1f · x/%.1f)" % [float(wave.amplitude), float(wave.frequency), float(wave.length)]
	return text
