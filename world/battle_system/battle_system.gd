extends Node

const Formula = preload("res://core/combat/trajectory_formula.gd")
const Targeting = preload("res://core/combat/trajectory_targeting.gd")
const Effects = preload("res://core/combat/card_effects.gd")
const Builder = preload("res://world/combat/encounter_builder.gd")
const Generator = preload("res://core/run/run_generator.gd")
const GAME_OVER = preload("res://interface/game_over_screen.tscn")
const REWARD = preload("res://interface/reward_screen.tscn")
enum Phase { SETUP, PLAYER, RESOLVING, ENEMIES, FINISHED }
var phase := Phase.SETUP
var formula = Formula.new()
var current_enemies: Array = []
var player: Node2D
var trajectory: Line2D
var combat_ui: CanvasLayer
var scenario_container: Node2D
var is_boss_fight := false
@export var lock_distance := 65.0
@export var player_damage := 15
@export var combat_ui_scene: PackedScene = preload("res://interface/interface.tscn")

func _ready() -> void:
	GameManager.current_context = GameManager.Context.COMBAT
	if not GameManager.scenario_to_load.is_empty():
		scenario_container = load(GameManager.scenario_to_load).instantiate()
		is_boss_fight = GameManager.scenario_to_load.contains("boss")
	else:
		var spec: Dictionary = GameManager.current_encounter
		if spec.is_empty():
			spec = Generator.encounter({"seed": 42,"tier": 1,"kind": "combat"})
		scenario_container = Builder.build(spec)
		is_boss_fight = spec.boss
	add_child(scenario_container)
	_name_enemies()
	player = scenario_container.get_node("player")
	trajectory = player.trajectory
	combat_ui = combat_ui_scene.instantiate()
	add_child(combat_ui)
	combat_ui.end_turn_requested.connect(execute_turn_actions)
	combat_ui.selection_changed.connect(rebuild_cards_formula)
	combat_ui.card_hover_changed.connect(_on_card_hover_changed)
	player.status_changed.connect(update_player_interface)
	update_player_interface()
	await _start_player_turn(false)

func _name_enemies() -> void:
	var counts := {}
	var indices := {}
	var enemies: Array = []
	for enemy in scenario_container.get_children():
		if enemy.is_in_group("enemies"):
			enemies.append(enemy)
			counts[enemy.display_name] = int(counts.get(enemy.display_name, 0)) + 1
	for enemy in enemies:
		var base_name: String = enemy.display_name
		indices[base_name] = int(indices.get(base_name, 0)) + 1
		enemy.combat_name = "%s %d" % [base_name, indices[base_name]] if counts[base_name] > 1 else base_name
		enemy._refresh_hud()

func _physics_process(_delta: float) -> void:
	if phase == Phase.PLAYER:
		evaluate_trajectory()

func can_edit_selection() -> bool:
	return phase == Phase.PLAYER

func get_pause_details() -> String:
	var state: String = {Phase.PLAYER: "Sua vez", Phase.ENEMIES: "Inimigos", Phase.RESOLVING: "Resolvendo ações", Phase.SETUP: "Preparando", Phase.FINISHED: "Finalizado"}[phase]
	var tier := clampi(int(GameManager.current_encounter.get("tier", 1)), 1, Generator.TIERS.size())
	return "Turno %d • %s\nEtapa %d/7 • %s\nModo %s" % [combat_ui.turn_count, state, mini(GameManager.level + 1, 7), Generator.TIERS[tier - 1], "Difícil" if GameManager.hard_mode else "Normal"]

func _start_player_turn(new_round: bool) -> void:
	phase = Phase.RESOLVING
	await player.begin_turn()
	if await _finish_if_needed():
		return
	if new_round:
		combat_ui.start_new_player_round()
	phase = Phase.PLAYER
	combat_ui.set_player_turn(true)
	rebuild_cards_formula([])

func rebuild_cards_formula(cards: Array) -> void:
	if not can_edit_selection():
		return
	formula.rebuild(cards)
	trajectory.show_formula(formula)
	combat_ui.update_equation(formula.equation_text())
	evaluate_trajectory()

func evaluate_trajectory() -> void:
	clear_target()
	var points := PackedVector2Array()
	for point in trajectory.points:
		points.append(trajectory.to_global(point))
	for enemy in scenario_container.get_children():
		if is_instance_valid(enemy) and enemy.is_in_group("enemies") and enemy.check_is_alive():
			if Targeting.hits(points, enemy.global_position, lock_distance):
				current_enemies.append(enemy)
				enemy.lock()

func clear_target() -> void:
	for enemy in current_enemies:
		if is_instance_valid(enemy):
			enemy.unlock()
	current_enemies.clear()

func execute_turn_actions() -> void:
	if phase != Phase.PLAYER:
		return
	evaluate_trajectory()
	phase = Phase.RESOLVING
	combat_ui.set_player_turn(false)
	var targets := current_enemies.duplicate()
	var cards: Array = combat_ui.commit_selection()
	var effects := Effects.aggregate(cards)
	trajectory.clear_points()
	clear_target()
	player.apply_effects(effects)
	if not targets.is_empty():
		await player.play_attack()
		for enemy in targets:
			if is_instance_valid(enemy) and enemy.check_is_alive():
				enemy.receive_vulnerable(int(effects.vulnerable))
				await enemy.take_damage(player.attack_damage(player_damage + int(effects.damage)), int(effects.pierce) > 0)
				if is_instance_valid(enemy) and enemy.check_is_alive():
					enemy.receive_poison(int(effects.poison))
	player.finish_turn()
	combat_ui.update_equation("y = 0")
	if await _finish_if_needed():
		return
	phase = Phase.ENEMIES
	for enemy in scenario_container.get_children():
		if is_instance_valid(enemy) and enemy.is_in_group("enemies") and enemy.check_is_alive():
			await enemy.take_turn()
			if await _finish_if_needed():
				return
			await get_tree().create_timer(0.25).timeout
	await _start_player_turn(true)

func _finish_if_needed() -> bool:
	if phase == Phase.FINISHED:
		return true
	if not player.check_is_alive():
		phase = Phase.FINISHED
		await player.play_death()
		add_child(GAME_OVER.instantiate())
		return true
	for enemy in scenario_container.get_children():
		if is_instance_valid(enemy) and enemy.is_in_group("enemies") and enemy.check_is_alive():
			return false
	phase = Phase.FINISHED
	GameManager.complete_combat(is_boss_fight)
	add_child(REWARD.instantiate())
	return true

func update_player_interface() -> void:
	combat_ui.update_player_status(player.get_player_status())

func _on_card_hover_changed(hovered: bool) -> void:
	if phase == Phase.PLAYER:
		if hovered:
			player.on_card_hovered()
		else:
			player.on_card_exited()
