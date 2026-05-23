extends Node2D

const CARDS = preload("res://card/card_database.gd").CARDS
const card_scene = preload("res://card/card.tscn")
const player_scene = preload("res://world/player/player.tscn")

@onready var trajectory = $Trajectory
@onready var camera = $Camera2D

func _ready():
	var player = player_scene.instantiate()
	add_child(player)
	player.global_position = Vector2.ZERO
	camera.global_position = Vector2(500, 0)

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
