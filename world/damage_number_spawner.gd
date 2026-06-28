extends Node

const damage_number_scene = preload("res://world/damage_number.tscn")

const COLOR_ENEMY = Color(1.0, 0.85, 0.0)
const COLOR_PLAYER = Color(1.0, 0.2, 0.2)

func spawn(world_position: Vector2, amount: int, color: Color) -> void:
	var instance = damage_number_scene.instantiate()
	get_tree().current_scene.add_child(instance)
	instance.global_position = world_position
	instance.setup(amount, color)
