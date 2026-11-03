extends Node

const Catalog = preload("res://card/card_database.gd")
const Generator = preload("res://core/run/run_generator.gd")
const MAIN_SCENE := "res://main/main.tscn"
const BATTLE_SCENE := "res://world/battle_system/battle_system.tscn"
const MAP_SCENE := "res://world/map/procedural_map.tscn"
const FINAL_LEVEL := Generator.ROW_COUNT

enum Context { MAIN_MENU, MAP, COMBAT, SETUP, REWARD, FINISHED }
var current_context := Context.MAIN_MENU
var scenario_to_load := "" # Somente para abrir os cenários antigos no editor.
var map_to_load := "map_1"
var max_player_health := 80
var player_health := max_player_health
var level := 0
var hard_mode := false
var run_seed := 0
var run_deck: Array = []
var map_rows: Array = []
var available_nodes: Array = []
var visited_nodes: Array = []
var current_node: Dictionary = {}
var current_encounter: Dictionary = {}
var pending_rewards: Array = []
var reward_pending := false
var run_complete := false
var victories := 0
var _changing_scene := false

func _ready() -> void:
	get_tree().scene_changed.connect(func(): _changing_scene = false)

func reset_run() -> void:
	player_health = max_player_health
	level = 0
	hard_mode = false
	run_seed = 0
	run_deck.clear()
	map_rows.clear()
	available_nodes.clear()
	visited_nodes.clear()
	current_node.clear()
	current_encounter.clear()
	pending_rewards.clear()
	reward_pending = false
	run_complete = false
	victories = 0
	scenario_to_load = ""

func start_run() -> void:
	_change_scene("res://interface/run_setup.tscn", Context.SETUP)

func prepare_run(difficult: bool, fixed_seed: int = -1) -> void:
	reset_run()
	hard_mode = difficult
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	run_seed = fixed_seed if fixed_seed >= 0 else int(rng.randi())
	run_deck = Catalog.STARTER_DECK.duplicate()
	map_rows = Generator.generate(run_seed)
	for node in map_rows[0]:
		available_nodes.append(node.id)

func begin_run(difficult: bool, fixed_seed: int = -1) -> void:
	if _changing_scene:
		return
	prepare_run(difficult, fixed_seed)
	return_to_map()

func get_run_deck() -> Array:
	return Catalog.STARTER_DECK.duplicate() if run_deck.is_empty() else run_deck.duplicate()

func select_map_node(id: String) -> bool:
	if _changing_scene or reward_pending or run_complete or not available_nodes.has(id):
		return false
	var node := Generator.find_node(map_rows, id)
	if node.is_empty() or visited_nodes.has(id):
		return false
	current_node = node.duplicate(true)
	if node.kind == "rest":
		complete_rest()
	else:
		current_encounter = Generator.encounter(node)
		scenario_to_load = ""
		_change_scene(BATTLE_SCENE, Context.COMBAT)
	return true

func start_combat(path: String) -> void:
	# Compatibilidade para a equipe inspecionar cenas antigas com F6.
	if _changing_scene or not ResourceLoader.exists(path, "PackedScene"):
		return
	scenario_to_load = path
	current_encounter.clear()
	_change_scene(BATTLE_SCENE, Context.COMBAT)

func complete_combat(boss: bool) -> void:
	if reward_pending:
		return
	victories += 1
	reward_pending = true
	run_complete = boss
	_finish_node()
	pending_rewards = Catalog.reward_choices(run_seed + victories * 7919 + int(current_encounter.get("seed", 0)))

func claim_reward(card_id: int = -1) -> bool:
	if not reward_pending:
		return false
	if card_id != -1:
		var found := false
		for card in pending_rewards:
			if int(card.id) == card_id:
				found = true
				break
		if not found:
			return false
		if run_deck.is_empty():
			run_deck = Catalog.STARTER_DECK.duplicate()
		run_deck.append(card_id)
	reward_pending = false
	pending_rewards.clear()
	current_encounter.clear()
	current_node.clear()
	return true

func continue_after_reward() -> void:
	if reward_pending:
		return
	if run_complete:
		_change_scene("res://interface/run_complete.tscn", Context.FINISHED)
	else:
		return_to_map()

func complete_rest() -> void:
	player_health = mini(player_health + int(max_player_health * 0.30), max_player_health)
	_finish_node()
	current_node.clear()
	return_to_map()

func _finish_node() -> void:
	if current_node.is_empty():
		level += 1
		return
	if not visited_nodes.has(current_node.id):
		visited_nodes.append(current_node.id)
		level = int(current_node.row) + 1
		available_nodes = current_node.next.duplicate()

func return_to_map() -> void:
	if reward_pending:
		return
	if map_rows.is_empty():
		prepare_run(hard_mode)
	scenario_to_load = ""
	_change_scene(MAP_SCENE, Context.MAP)

func return_to_menu() -> void:
	if _changing_scene:
		return
	reset_run()
	_change_scene(MAIN_SCENE, Context.MAIN_MENU)

func _change_scene(path: String, context: Context) -> void:
	if _changing_scene:
		return
	_changing_scene = true
	get_tree().paused = false
	var previous := get_tree().current_scene
	if is_instance_valid(previous):
		_stop_audio(previous)
	var error := get_tree().change_scene_to_file(path)
	if error != OK:
		_changing_scene = false
		push_error("Falha ao trocar de cena: %s (%s)" % [path, error])
	else:
		current_context = context

func _stop_audio(node: Node) -> void:
	if node is AudioStreamPlayer:
		node.stop()
	for child in node.get_children():
		_stop_audio(child)
