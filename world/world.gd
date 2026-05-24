extends Node2D

const CARDS = preload("res://card/card_database.gd").CARDS
const card_scene = preload("res://card/card.tscn")
const player_scene = preload("res://world/player/player.tscn")

@onready var camera = $Camera

var player_instance: Node2D
var trajectory: Node2D

var current_math_x: float = 0.0
var current_math_y: float = 0.0

func _ready():
	player_instance = player_scene.instantiate()
	add_child(player_instance)
	player_instance.global_position = Vector2.ZERO
	camera.global_position = Vector2(500, 0)
	trajectory = player_instance.get_node("TrajectoryNode/Trajectory")

func apply_card(value: int, axis: String):
	if not trajectory:
		print("trajectory line doesn't exists!")
		return
	
	if axis == "x":
		print(value)
		print(current_math_x)
		if (current_math_x <= 1 && value < 0):
			current_math_x = 0
		else:
			current_math_x += value
		
	if axis == "y":
		current_math_y += value
		
	if axis != "x" && axis != "y":
		print("invalid axis move!")
		return

	trajectory.update_straight_line(current_math_x, current_math_y)
