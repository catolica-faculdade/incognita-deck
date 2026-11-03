extends Line2D
## Somente apresentação: a fórmula calcula os pontos em core/combat.

@export var grid_unity: float = 75.0
@export var curve_resolution: int = 40

func _ready() -> void:
	points = PackedVector2Array([Vector2.ZERO])

func show_formula(formula: RefCounted) -> void:
	points = formula.sample(grid_unity, curve_resolution)
