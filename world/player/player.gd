extends CharacterBody2D

const trajectory_scene = preload("res://world/player/trajectory.tscn")

func _ready() -> void:
	global_position = Vector2(100, 0)
	var trajectory = trajectory_scene.instantiate()
	add_child(trajectory)
