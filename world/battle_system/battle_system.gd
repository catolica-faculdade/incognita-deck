extends Node

@export var lock_distance = 75
@export var combat_ui_scene = preload("res://interface/interface.tscn")

const game_over_scene = preload("res://interface/game_over_screen.tscn")
const victory_scene = preload("res://interface/victory_screen.tscn")
var is_boss_fight := false

signal card_pressed(card_data: Dictionary)

var card_payload: Dictionary
var is_turn_running := false

var wave_enabled := false
var wave_amplitude := 0.0
var wave_frequency := 0.0
var wave_length := 0.0

var scenario_container: Node2D
var combat_ui: CanvasLayer
var player_interface

var trajectory: Node2D
var player_damage = 15

var current_enemies = []

var current_math_x: float = 0.0
var current_math_y: float = 0.0

var quadratic_a: float = 0.0
var quadratic_b: float = 0.0
var quadratic_c: float = 0.0


func _ready() -> void:
	GameManager.is_player_turn = true
	is_turn_running = false

	scenario_container = Node2D.new()
	scenario_container.name = "CenarioContainer"
	add_child(scenario_container)
	GameManager.current_context = GameManager.Context.COMBAT

	var scenario_to_load = GameManager.scenario_to_load
	is_boss_fight = GameManager.scenario_to_load.contains("boss")

	if scenario_to_load != "":
		print("BattleSystem: Carregando o cenário -> ", scenario_to_load)

		var cenario_prefab = load(scenario_to_load)
		var cenario_instancia = cenario_prefab.instantiate()

		scenario_container.add_child(cenario_instancia)

		trajectory = cenario_instancia.find_child("Trajectory", true, false)

		if trajectory:
			print("BattleSystem: Trajetória encontrada!")
		else:
			print("Erro: Trajectory não encontrada!")
	else:
		print("Aviso: Nenhum cenário foi especificado!")

	if combat_ui_scene:
		combat_ui = combat_ui_scene.instantiate() as CanvasLayer
		add_child(combat_ui)
		combat_ui.show()

		if combat_ui.has_method("set_battle_system"):
			combat_ui.set_battle_system(self)

		player_interface = combat_ui.find_child("PlayerInterface", true, false)

		if player_interface:
			update_player_interface()
		else:
			print("PlayerInterface não encontrada!")

		var player = get_tree().get_first_node_in_group("Player")

		if player:
			player.status_changed.connect(update_player_interface)
			update_player_interface()
		else:
			print("Player não encontrado!")

		var end_turn_button = combat_ui.find_child("EndTurnButton", true, false)
		var clear_button = combat_ui.find_child("ClearTrajectoryButton", true, false)

		if end_turn_button:
			if end_turn_button.end_turn.is_connected(execute_turn_actions):
				end_turn_button.end_turn.disconnect(execute_turn_actions)

			end_turn_button.end_turn.connect(execute_turn_actions)
			print("BattleSystem: EndTurn conectado com sucesso!")
		else:
			print("Aviso: Botão 'EndTurnButton' não foi encontrado na cena de interface.")

		if clear_button:
			if clear_button.clear_trajectory.is_connected(clear_trajectory):
				clear_button.clear_trajectory.disconnect(clear_trajectory)

			clear_button.clear_trajectory.connect(clear_trajectory)
			print("BattleSystem: ClearTrajectory conectado com sucesso!")
		else:
			print("ClearTrajectoryButton não encontrado!")

		print("BattleSystem: Interface carregada com sucesso!")


func setup(card_data: Dictionary):
	card_payload = card_data


func _on_pressed():
	card_pressed.emit(card_payload)


func clear_target():
	for enemy in current_enemies:
		if is_instance_valid(enemy) and enemy.has_method("unlock"):
			enemy.unlock()

	current_enemies = []


func lock_target(enemy):
	current_enemies.push_back(enemy)


func evaluate_trajectory(points):
	clear_target()

	var enemies = get_tree().get_nodes_in_group("enemies")

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
	combat_ui.set_turn_indicator(false)

	await player_attack_phase()
	if await is_end_combat():
		return

	await enemy_turn_phase()
	if await is_end_combat():
		return

	start_player_turn()


func start_player_turn() -> void:
	print("Turno do jogador!")

	GameManager.is_player_turn = true
	is_turn_running = false
	combat_ui.set_turn_indicator(true)

	clear_trajectory()

	if combat_ui and combat_ui.has_method("start_new_player_round"):
		combat_ui.start_new_player_round()

func enemy_turn_phase() -> void:
	print("Turno dos inimigos!")
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("on_end_turn"):
		await player.on_end_turn()
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.health > 0:
			if enemy.has_method("choose_action"):
				await enemy.choose_action()

				if not is_inside_tree():
					return

				await get_tree().create_timer(1.0).timeout

	is_end_combat()


func player_attack_phase() -> void:
	if current_enemies.size() > 0:
		var player = get_tree().get_first_node_in_group("Player")
		if player and player.has_method("play_attack"):
			await player.play_attack()
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

	is_end_combat()


func apply_card(card: Dictionary):
	if not GameManager.is_player_turn or is_turn_running:
		print("Não é turno do jogador!")
		return

	if not trajectory:
		print("trajectory line doesn't exist!")
		return

	var applied := _apply_card_math(card)

	if not applied:
		return

	update_trajectory()

	if trajectory:
		evaluate_trajectory(trajectory.points)

	if combat_ui.has_method("update_equation"):
		combat_ui.update_equation(get_equation_text())


func rebuild_cards_formula(cards: Array):
	if not GameManager.is_player_turn or is_turn_running:
		print("Não é turno do jogador!")
		return

	if not trajectory:
		print("trajectory line doesn't exist!")
		return

	reset_math()
	clear_target()

	if trajectory:
		trajectory.clear_points()
		trajectory.add_point(Vector2.ZERO)

	for card in cards:
		_apply_card_math(card)

	if cards.size() > 0:
		update_trajectory()

		if trajectory:
			evaluate_trajectory(trajectory.points)
	else:
		clear_target()

		if trajectory:
			trajectory.clear_points()
			trajectory.add_point(Vector2.ZERO)

	if combat_ui.has_method("update_equation"):
		combat_ui.update_equation(get_equation_text())


func _apply_card_math(card: Dictionary) -> bool:
	var type: String = card.get("type", "linear")

	if type == "linear":
		apply_linear_card(card)
	elif type == "quadratic":
		apply_quadratic_card(card)
	elif type == "special":
		apply_special_card(card)
	else:
		print("invalid card type!")
		return false

	return true


func is_end_combat() -> bool:
	if not is_inside_tree():
		return true


	var player = get_tree().get_first_node_in_group("Player")
	if player:
		var status = player.get_player_status()
		if status["health"] <= 0:
			is_turn_running = false
			GameManager.is_player_turn = true
			await show_game_over(player)
			return true

	var enemies = get_tree().get_nodes_in_group("enemies")
	var alive_enemies := 0
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.health > 0:
			alive_enemies += 1

	if alive_enemies <= 0:
		win_combat()
		return true

	return false

func show_game_over(player) -> void:
	if player.has_method("play_death"):
		await player.play_death()
	else:
		await get_tree().create_timer(1.0).timeout
	var screen = game_over_scene.instantiate()
	add_child(screen)

var combat_ended := false

func win_combat():
	if combat_ended:
		return
	combat_ended = true
	is_turn_running = false
	GameManager.is_player_turn = true
	if not is_boss_fight:
		GameManager.level += 1
	else:
		GameManager.level = 5
	var screen = victory_scene.instantiate()
	screen.setup(is_boss_fight)
	add_child(screen)



func apply_linear_card(card: Dictionary):
	var x_value: float = float(card.get("x", 0))
	var y_value: float = float(card.get("y", 0))

	current_math_x += x_value
	current_math_y += y_value


func apply_special_card(card: Dictionary):
	var special_type = card.get("special_type", "")

	if special_type == "wave":
		wave_enabled = true
		wave_amplitude += float(card.get("amplitude", 2.0))
		wave_frequency += float(card.get("frequency", 2.0))
		wave_length = max(wave_length, float(card.get("length", 8.0)))
	else:
		print("invalid special card: ", special_type)


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
	if not trajectory:
		return

	var has_quadratic := quadratic_a != 0.0 or quadratic_b != 0.0 or quadratic_c != 0.0
	var has_wave := wave_enabled

	var end_x := current_math_x

	if end_x <= 0:
		if has_wave:
			end_x = wave_length
		elif has_quadratic:
			end_x = 8.0

	if has_wave:
		trajectory.update_mixed_line(
			quadratic_a,
			quadratic_b,
			quadratic_c + current_math_y,
			0.0,
			end_x,
			wave_amplitude,
			wave_frequency
		)
	elif has_quadratic:
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

	wave_enabled = false
	wave_amplitude = 0.0
	wave_frequency = 0.0
	wave_length = 0.0


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

	reset_math()
	clear_target()

	if trajectory:
		trajectory.clear_points()
		trajectory.add_point(Vector2.ZERO)

	if combat_ui.has_method("update_equation"):
		combat_ui.update_equation("y = 0")

	print("Trajetória limpa!")


func update_player_interface():
	if not is_inside_tree():
		return

	var player = get_tree().get_first_node_in_group("Player")

	if not player:
		return

	if not player_interface:
		return

	var status = player.get_player_status()

	player_interface.update_player_info(
		status["health"],
		status["max_health"],
		status["poison"],
		status["shield"]
	)
