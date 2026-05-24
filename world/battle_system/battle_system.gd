extends Node

@export var lock_distance = 75

var current_enemy = null

func _ready() -> void:
	pass
	
func clear_target():
	if current_enemy:
		current_enemy.unlock()
	current_enemy = null
	
func lock_target(enemy):
	current_enemy = enemy
	enemy.lock()

func evaluate_trajectory(points: Array):
	clear_target()

	var enemies = get_tree().get_nodes_in_group("enemies")

	for enemy in enemies:

		if trajectory_hits_enemy(
			points,
			enemy.position
		):
			lock_target(enemy)
			return


func trajectory_hits_enemy(points: PackedVector2Array, enemy_position: Vector2) -> bool:
	for i in range(points.size() - 1):
		var a = points[i]
		var b = points[i + 1]
		var closest_point = Geometry2D.get_closest_point_to_segment(
			enemy_position,
			a,
			b
		)

		var distance = closest_point.distance_to(enemy_position)
		print("validando...", distance)
		print(lock_distance)
		if distance <= lock_distance:
			return true

	return false
