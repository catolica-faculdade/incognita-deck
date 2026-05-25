extends Node

@export var lock_distance = 75
@export var combat_ui_scene = preload("res://interface/interface.tscn")

var scenario_container: Node2D
var combat_ui: CanvasLayer
var trajectory: Node2D

var current_enemies = []

var current_math_x: float = 0.0
var current_math_y: float = 0.0

func _ready() -> void:
	scenario_container = Node2D.new()
	scenario_container.name = "CenarioContainer"
	add_child(scenario_container)
	
	var scenario_to_load = GameManager.scenario_to_load
	if scenario_to_load != "":
		print("BattleSystem: Carregando o cenário -> ", scenario_to_load)
		var cenario_prefab = load(scenario_to_load)
		var cenario_instancia = cenario_prefab.instantiate()
		scenario_container.add_child(cenario_instancia)
		trajectory = cenario_instancia.find_child("Trajectory", true, false)
		
		if trajectory:
			print("BattleSystem: Trajetória encontrada e mapeada com sucesso!")
		else:
			print("Erro crítico: Não foi possível encontrar o nó 'Trajectory' dentro do cenário!")
	else:
		print("Aviso: Nenhum cenário foi especificado no GameManager!")

	if combat_ui_scene:
		combat_ui = combat_ui_scene.instantiate() as CanvasLayer
		add_child(combat_ui)
		if combat_ui.has_method("set_battle_system"):
			combat_ui.set_battle_system(self)
		var end_turn_button = combat_ui.find_child("TextureButton", true, false)
		combat_ui.show()
		if end_turn_button:
			end_turn_button.end_turn.connect(execute_turn_actions)
			print("BattleSystem: Sinal de fim de turno conectado com sucesso!")
		else:
			print("Aviso: Botão 'TextureButton' não foi encontrado na cena de interface.")
		print("BattleSystem: Interface carregada com sucesso!")
	
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

		if trajectory_hits_enemy(points, enemy.global_position):
			lock_target(enemy)


func trajectory_hits_enemy(points: PackedVector2Array, enemy_global_position: Vector2) -> bool:
	for i in range(points.size() - 1):
		var a = points[i]
		var b = points[i + 1]
		var closest_point = Geometry2D.get_closest_point_to_segment(
			enemy_global_position,
			a,
			b
		)

		var distance = closest_point.distance_to(enemy_global_position)
		
		if distance <= lock_distance:
			return true

	return false

func execute_turn_actions() -> void:
	if current_enemies.size() > 0:
		print("Iniciando ataque aos inimigos selecionados: ", current_enemies.size())
		
		if trajectory:
			trajectory.clear_points()
			
		var enemies_to_attack = current_enemies.duplicate()
		
		var player_damage = 20
		for enemy in enemies_to_attack:
			if is_instance_valid(enemy) and enemy.health > 0:
				await enemy.take_damage(player_damage)
		clear_target()
	else:
		print("Nenhum inimigo selecionado na trajetória.")
		if trajectory:
			trajectory.clear_points()
			current_math_x = 0.0
			current_math_y = 0.0
			
func apply_card(value: int, axis: String):
	if not trajectory:
		print("trajectory line doesn't exist!")
		return
	
	if axis == "x":
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
	
	evaluate_trajectory(trajectory.points)
