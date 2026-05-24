extends Node

@onready var battle_system = $BattleSystem
@export var lock_distance = 40

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

func trajectory_hits_enemy(points: Array[float], position: Array[float]):
	if position == points:
		return true
	return false
