extends Line2D

@export var grid_unity: float = 75.0
@export var curve_resolution: int = 40

func _ready():
	clear_points()
	add_point(Vector2.ZERO)


func update_straight_line(x_position: float, y_position: float):
	clear_points()
	
	add_point(Vector2.ZERO)
	
	var final_x_position = x_position * grid_unity
	var final_y_position = y_position * grid_unity * -1
	
	add_point(Vector2(final_x_position, final_y_position))


func update_quadratic_line(a: float, b: float, c: float, start_x: float, end_x: float):
	clear_points()
	
	for i in range(curve_resolution + 1):
		var t: float = float(i) / curve_resolution
		var x: float = lerp(start_x, end_x, t)
		var y: float = a * x * x + b * x + c
		
		var screen_x: float = x * grid_unity
		var screen_y: float = y * grid_unity * -1
		
		add_point(Vector2(screen_x, screen_y))
