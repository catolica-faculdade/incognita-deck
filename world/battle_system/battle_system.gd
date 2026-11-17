extends Node

const Formula = preload("res://core/combat/trajectory_formula.gd")
const Catalog = preload("res://card/card_database.gd")
const Targeting = preload("res://core/combat/trajectory_targeting.gd")
const Reflection = preload("res://core/combat/trajectory_reflection.gd")
const Effects = preload("res://core/combat/card_effects.gd")
const Builder = preload("res://world/combat/encounter_builder.gd")
const Generator = preload("res://core/run/run_generator.gd")
const GAME_OVER = preload("res://interface/game_over_screen.tscn")
const REWARD = preload("res://interface/reward_screen.tscn")
const WATER_SHOT = preload("res://assets/projectiles/water_doodle.png")
const PROJECTILE_SPEED := 1100.0
const TURN_MIRROR_SLOTS := [Vector2(350, -258), Vector2(553, -319), Vector2(746, -307), Vector2(940, -280)]
const MIRROR_LIMIT := 4
enum Phase { SETUP, PLAYER, RESOLVING, ENEMIES, FINISHED }
var phase := Phase.SETUP
var formula = Formula.new()
var current_enemies: Array = []
var trajectory_contacts: Array[Dictionary] = []
var trajectory_points := PackedVector2Array()
var mirror_segments: Array[PackedVector2Array] = []
var turn_mirror_drawings: Array[Node2D] = []
var preview_shot: Sprite2D
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
	var spec: Dictionary = {}
	if not GameManager.scenario_to_load.is_empty():
		scenario_container = load(GameManager.scenario_to_load).instantiate()
		is_boss_fight = GameManager.scenario_to_load.contains("boss")
	else:
		spec = GameManager.current_encounter
		if spec.is_empty():
			spec = Generator.encounter({"seed": 42,"tier": 1,"kind": "combat"})
		scenario_container = Builder.build(spec)
		is_boss_fight = spec.boss
	add_child(scenario_container)
	_name_enemies()
	player = scenario_container.get_node("player")
	trajectory = player.trajectory
	preview_shot = _make_shot(25.0)
	preview_shot.modulate.a = 0.75
	preview_shot.hide()
	trajectory.add_child(preview_shot)
	for segment: PackedVector2Array in spec.get("mirrors", []):
		_register_mirror(segment)
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
			enemy.mirror_requested.connect(_place_turn_mirror)
			counts[enemy.display_name] = int(counts.get(enemy.display_name, 0)) + 1
	for enemy in enemies:
		var base_name: String = enemy.display_name
		indices[base_name] = int(indices.get(base_name, 0)) + 1
		enemy.combat_name = "%s %d" % [base_name, indices[base_name]] if counts[base_name] > 1 else base_name
		enemy._refresh_hud()

func can_edit_selection() -> bool:
	return phase == Phase.PLAYER

func get_pause_details() -> String:
	var state: String = {Phase.PLAYER: "Sua vez", Phase.ENEMIES: "Inimigos", Phase.RESOLVING: "Resolvendo ações", Phase.SETUP: "Preparando", Phase.FINISHED: "Finalizado"}[phase]
	var tier := clampi(int(GameManager.current_encounter.get("tier", 1)), 1, Generator.TIERS.size())
	return "Turno %d • %s\n%s • %s\nModo %s" % [combat_ui.turn_count, state, GameManager.stage_text(), Generator.TIERS[tier - 1], "Difícil" if GameManager.hard_mode else "Normal"]

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
	trajectory.points = projected_path(formula)
	preview_shot.visible = trajectory.points.size() >= 2
	if preview_shot.visible:
		preview_shot.position = trajectory.points[-1]
		preview_shot.rotation = (trajectory.points[-1] - trajectory.points[-2]).angle()
	combat_ui.update_equation(formula.equation_text())
	evaluate_trajectory()

func projected_path(composition: RefCounted) -> PackedVector2Array:
	return Reflection.reflect_path(trajectory.sample_formula(composition), mirror_segments)

func evaluate_trajectory() -> void:
	clear_target()
	for point in trajectory.points:
		trajectory_points.append(trajectory.to_global(point))
	for enemy in scenario_container.get_children():
		if is_instance_valid(enemy) and enemy.is_in_group("enemies") and enemy.check_is_alive():
			var center: Vector2 = scenario_container.to_global(enemy.start_position)
			var distances := Targeting.contacts(trajectory_points, center, lock_distance)
			if not distances.is_empty():
				current_enemies.append(enemy)
				enemy.lock()
				for distance in distances:
					trajectory_contacts.append({"distance": distance, "enemy": enemy, "center": center})
	trajectory_contacts.sort_custom(func(a: Dictionary, b: Dictionary): return a.distance < b.distance)

func clear_target() -> void:
	for enemy in current_enemies:
		if is_instance_valid(enemy):
			enemy.unlock()
	current_enemies.clear()
	trajectory_contacts.clear()
	trajectory_points.clear()

func execute_turn_actions() -> void:
	if phase != Phase.PLAYER:
		return
	evaluate_trajectory()
	phase = Phase.RESOLVING
	combat_ui.set_player_turn(false)
	var contacts := trajectory_contacts.duplicate()
	var points := trajectory_points.duplicate()
	var cards: Array = combat_ui.commit_selection()
	var effects := Effects.aggregate(cards)
	var uses_spiral := cards.any(func(card: Dictionary): return card.type == "spiral")
	clear_target()
	preview_shot.hide()
	player.apply_effects(effects)
	if points.size() >= 2:
		await player.play_attack()
		await _fire_projectile(points, contacts, effects, uses_spiral)
	trajectory.clear_points()
	_clear_turn_mirrors()
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

func _fire_projectile(points: PackedVector2Array, contacts: Array, effects: Dictionary, uses_spiral: bool) -> void:
	var distances := PackedFloat32Array([0.0])
	for i in range(1, points.size()):
		distances.append(distances[-1] + points[i - 1].distance_to(points[i]))
	if is_zero_approx(distances[-1]):
		return

	var projectile := _make_shot(38.0)
	projectile.z_index = 10
	scenario_container.add_child(projectile)
	projectile.global_position = points[0]
	projectile.global_rotation = (points[1] - points[0]).angle()

	var hit_enemies := {}
	var traveled := 0.0
	var position_projectile := func(distance: float) -> void:
		for i in range(1, distances.size()):
			var length := distances[i] - distances[i - 1]
			if length > 0.0 and distance < distances[i]:
				projectile.global_position = points[i - 1].lerp(points[i], (distance - distances[i - 1]) / length)
				projectile.global_rotation = (points[i] - points[i - 1]).angle()
				return
		projectile.global_position = points[-1]
		projectile.global_rotation = (points[-1] - points[-2]).angle()
	for contact in contacts:
		await _move_projectile(position_projectile, traveled, contact.distance)
		traveled = contact.distance
		var enemy = contact.enemy
		if not is_instance_valid(enemy) or not enemy.check_is_alive():
			continue
		# A reação do Professor pode invalidar uma segunda passagem prevista.
		if not scenario_container.to_global(enemy.start_position).is_equal_approx(contact.center):
			continue
		var hits := int(hit_enemies.get(enemy, 0))
		if uses_spiral and hits > Catalog.SPIRAL_REPEAT_LIMIT:
			continue
		hit_enemies[enemy] = hits + 1
		var repeated := hits > 0
		var damage: int = player.attack_damage(player_damage + int(effects.damage))
		if repeated and uses_spiral:
			damage = floori(damage * Catalog.SPIRAL_REPEAT_DAMAGE)
		enemy.receive_vulnerable(_hit_effect(int(effects.vulnerable), repeated))
		await enemy.take_damage(damage, int(effects.pierce) > 0)
		if is_instance_valid(enemy) and enemy.check_is_alive():
			enemy.receive_poison(_hit_effect(int(effects.poison), repeated))
	await _move_projectile(position_projectile, traveled, distances[-1])
	projectile.queue_free()

func _make_shot(width: float) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = WATER_SHOT
	sprite.scale = Vector2.ONE * width / WATER_SHOT.get_width()
	return sprite

func _register_mirror(segment: PackedVector2Array) -> void:
	mirror_segments.append(PackedVector2Array([
		trajectory.to_local(scenario_container.to_global(segment[0])),
		trajectory.to_local(scenario_container.to_global(segment[1]))
	]))

func _place_turn_mirror() -> void:
	if mirror_segments.size() >= MIRROR_LIMIT:
		return
	var half_segment := Vector2(25, 25 if combat_ui.turn_count % 2 == 0 else -25)
	for center: Vector2 in TURN_MIRROR_SLOTS:
		var start := center - half_segment
		var finish := center + half_segment
		if not _mirror_space_is_clear(start, finish):
			continue
		var segment := PackedVector2Array([start, finish])
		_register_mirror(segment)
		turn_mirror_drawings.append(Builder.draw_mirror(scenario_container, segment))
		return

func _mirror_space_is_clear(start: Vector2, finish: Vector2) -> bool:
	for enemy in scenario_container.get_children():
		if enemy.is_in_group("enemies") and enemy.check_is_alive():
			var nearest := Geometry2D.get_closest_point_to_segment(enemy.start_position, start, finish)
			if nearest.distance_to(enemy.start_position) < lock_distance:
				return false
	var local_start := trajectory.to_local(scenario_container.to_global(start))
	var local_finish := trajectory.to_local(scenario_container.to_global(finish))
	var center := (local_start + local_finish) * 0.5
	for mirror in mirror_segments:
		if Geometry2D.get_closest_point_to_segment(center, mirror[0], mirror[1]).distance_to(center) < 65.0:
			return false
	return true

func _clear_turn_mirrors() -> void:
	mirror_segments.resize(mirror_segments.size() - turn_mirror_drawings.size())
	for drawing in turn_mirror_drawings:
		drawing.queue_free()
	turn_mirror_drawings.clear()

func _move_projectile(position_projectile: Callable, from: float, to: float) -> void:
	if to > from:
		var tween := create_tween()
		tween.tween_method(position_projectile, from, to, (to - from) / PROJECTILE_SPEED)
		await tween.finished

func _hit_effect(amount: int, repeated: bool) -> int:
	return mini(amount, 1) if repeated else amount

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
