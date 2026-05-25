extends Node

@export var lock_distance = 75
@export var combat_ui_scene = preload("res://interface/interface.tscn")

signal card_pressed(card_data: Dictionary)

var data: Dictionary
var is_turn_running := false

var scenario_container: Node2D
var combat_ui: CanvasLayer
var trajectory: Node2D
var player_damage = 5

var current_enemies = []

var current_math_x: float = 0.0
var current_math_y: float = 0.0

var quadratic_a: float = 0.0
var quadratic_b: float = 0.0
var quadratic_c: float = 0.0

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
	
	var end_turn_button = combat_ui.find_child("EndTurnButton", true, false)
	var clear_button = combat_ui.find_child("ClearTrajectoryButton", true, false)

	if end_turn_button:
		end_turn_button.end_turn.connect(execute_turn_actions)
		print("EndTurn conectado!")

	if clear_button:
		clear_button.clear_trajectory.connect(clear_trajectory)
		print("ClearTrajectory conectado!")


func setup(card_data: Dictionary):
	data = card_data
	

func _on_pressed():
	card_pressed.emit(data)
	
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
	print("enemies? ", enemies)
	
	var global_points := PackedVector2Array()
	if trajectory:
		for point in points:
			global_points.append(trajectory.to_global(point))

	for enemy in enemies:
		if trajectory_hits_enemy(global_points, enemy.global_position):
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
	if not GameManager.is_player_turn or is_turn_running:
		return
		
	is_turn_running = true
	GameManager.is_player_turn = false

	await player_attack_phase()
	await enemy_turn_phase()

	start_player_turn()
	
func start_player_turn() -> void:
	print("Turno do jogador!")

	GameManager.is_player_turn = true
	is_turn_running = false

	clear_trajectory()
	
func enemy_turn_phase() -> void:
	print("Turno dos inimigos!")

	var enemies = get_tree().get_nodes_in_group("enemies")

	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.health > 0:
			if enemy.has_method("choose_action"):
				await enemy.choose_action()
				await get_tree().create_timer(1.0).timeout
	
func player_attack_phase() -> void:
	if current_enemies.size() > 0:
		print("Iniciando ataque aos inimigos selecionados: ", current_enemies.size())

		var enemies_to_attack = current_enemies.duplicate()

		if trajectory:
			trajectory.clear_points()

		reset_math()

		for enemy in enemies_to_attack:
			if is_instance_valid(enemy) and enemy.health > 0:
				await enemy.take_damage(player_damage)

		clear_target()
	else:
		print("Nenhum inimigo selecionado na trajetória.")

		if trajectory:
			trajectory.clear_points()

		reset_math()

	if combat_ui.has_method("update_equation"):
		combat_ui.update_equation("y = 0")

func apply_card(card: Dictionary):
	if not GameManager.is_player_turn or is_turn_running:
		print("Não é turno do jogador!")
		return
	
	if not trajectory:
		print("trajectory line doesn't exist!")
		return
	
	var type: String = card.get("type", "linear")
	
	if type == "linear":
		apply_linear_card(card)
	elif type == "quadratic":
		apply_quadratic_card(card)
	else:
		print("invalid card type!")
		return
	
	update_trajectory()
	evaluate_trajectory(trajectory.points)
	if combat_ui.has_method("update_equation"):
		combat_ui.update_equation(get_equation_text())

func is_end_combat():
	if (current_enemies.size() <= 0):
		win_combat()


func win_combat():
	GameManager.level += 1
	GameManager.end_game()


func apply_linear_card(card: Dictionary):
	var axis: String = card.get("axis", "")
	var value: float = float(card.get("value", 0))
	
	if axis == "x":
		if current_math_x <= 1 and value < 0:
			current_math_x = 0
		else:
			current_math_x += value
	
	elif axis == "y":
		current_math_y += value
	
	else:
		print("invalid axis move!")


func apply_quadratic_card(card: Dictionary):
	var coefficient: String = card.get("coefficient", "")
	var value: float = float(card.get("value", 0))
	
	if coefficient == "a":
		quadratic_a += value
	elif coefficient == "b":
		quadratic_b += value
	elif coefficient == "c":
		quadratic_c += value
	else:
		print("invalid quadratic coefficient!")


func update_trajectory():
	var has_quadratic := quadratic_a != 0.0 or quadratic_b != 0.0 or quadratic_c != 0.0
	
	var end_x := current_math_x
	
	if has_quadratic and end_x <= 0:
		end_x = 8.0 # alcance padrão para visualizar curva
	
	if has_quadratic:
		trajectory.update_quadratic_line(
			quadratic_a,
			quadratic_b,
			quadratic_c + current_math_y,
			0.0,
			end_x
		)
	else:
		trajectory.update_straight_line(current_math_x, current_math_y)

func reset_math():
	current_math_x = 0.0
	current_math_y = 0.0
	quadratic_a = 0.0
	quadratic_b = 0.0
	quadratic_c = 0.0
	
func get_equation_text() -> String:
	var has_quadratic := quadratic_a != 0.0 or quadratic_b != 0.0
	
	if has_quadratic:
		return "y = %.1fx² + %.1fx + %.1f" % [
			quadratic_a,
			quadratic_b,
			quadratic_c + current_math_y
		]
	
	return "y = %.1f" % current_math_y
	
func clear_trajectory():
	print("função: clear trajectory")
	current_math_x = 0.0
	current_math_y = 0.0

	quadratic_a = 0.0
	quadratic_b = 0.0
	quadratic_c = 0.0

	clear_target()

	if trajectory:
		trajectory.clear_points()
		trajectory.add_point(Vector2.ZERO)
	
	if combat_ui.has_method("update_equation"):
		combat_ui.update_equation("y = 0")

	print("Trajetória limpa!")
