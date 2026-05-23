extends Node2D

@onready var trajectory = $Trajectory

const CARDS = preload("res://card/card_database.gd").CARDS
const card_scene = preload("res://card/card.tscn")

func _ready():

	create_card(CARDS[0], Vector2(100, 300))
	create_card(CARDS[1], Vector2(300, 300))
	create_card(CARDS[2], Vector2(500, 300))

func create_card(data, pos):

	var card = card_scene.instantiate()
	add_child(card)
	card.setup(data)
	card.position = pos


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
