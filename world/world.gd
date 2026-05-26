extends Node2D

const grid_unity = 75

const CARDS = preload("res://card/card_database.gd").CARDS
const card_scene = preload("res://card/card.tscn")
const player_scene = preload("res://world/player/player.tscn")
const enemy_scene = preload("res://world/enemy/enemy.tscn")
const calculator_scene = preload("res://world/enemy/enemy_combat/calculator/calculator_combat.tscn")

@onready var battle_system = $BattleSystemNode
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

func spawn_mock_enemy():
	var enemy = calculator_scene.instantiate()
	add_child(enemy)

func grid_to_world(grid: Vector2) -> Vector2:
	return Vector2(grid.x * 75, grid.y * -75)
