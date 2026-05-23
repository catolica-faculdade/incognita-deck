extends Node2D

@onready var button = $FakeCard
@onready var trajectory = $Trajectory

func _ready():

	button.pressed.connect(
		func():
			apply_card(1, "y")
	)

func _on_button_pressed():

	var new_points = []

	for point in trajectory.points:
		new_points.append(point + Vector2(0, -50))

	trajectory.points = new_points

func apply_card(value: int, axis: String):
	
	print("values: ", value)
	print("axis: ", axis)

	var offset = Vector2.ZERO

	if axis == "x":
		offset.x += value * 50

	if axis == "y":
		offset.y -= value * 50

	var new_points = []

	for point in trajectory.points:
		new_points.append(point + offset)

	trajectory.points = new_points
