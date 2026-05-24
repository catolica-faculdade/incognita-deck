extends Node

@export var lock_distance = 75
@onready var trajectory = $"../PlayerNode/TrajectoryNode/Trajectory"

var current_enemies = []

func _ready() -> void:
	pass
	
func clear_target():
	for enemy in current_enemies:
		if is_instance_valid(enemy) and enemy.has_method("unlock"):
			enemy.unlock()
	
	current_enemies = []
	
func lock_target(enemy):
	current_enemies.push_back(enemy)

func evaluate_trajectory(points: Array):
	clear_target()

	var enemies = get_tree().get_nodes_in_group("enemies")

	for enemy in enemies:

		if trajectory_hits_enemy(points, enemy.position):
			lock_target(enemy)


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
		print(lock_distance)
		if distance <= lock_distance:
			return true

	return false

func execute_turn_actions() -> void:
	if current_enemies.size() > 0:
		print("Iniciando ataque aos inimigos selecionados: ", current_enemies.size())
		
		if trajectory:
			trajectory.clear_points()
			
		var enemies_to_attack = current_enemies.duplicate()
		
		var player_damage = 5
		for enemy in enemies_to_attack:
			if is_instance_valid(enemy) and enemy.health > 0:
				await enemy.take_damage(player_damage)
		clear_target()
	else:
		print("Nenhum inimigo selecionado na trajetória.")
		if trajectory:
			trajectory.clear_points()
