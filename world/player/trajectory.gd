extends Line2D

@export var grid_unity: float = 75.0

func _ready():
	clear_points()
	add_point(Vector2.ZERO)

func update_straight_line(x_position: float, y_position: float):
	clear_points()
	
	add_point(Vector2.ZERO)
	
	var final_x_position = x_position * grid_unity
	var final_y_position = y_position * grid_unity * -1
	
	var final_position = Vector2(final_x_position, final_y_position)
	add_point(final_position)
