extends Node

const Catalog = preload("res://card/card_database.gd")
const Generator = preload("res://core/run/run_generator.gd")
const Save = preload("res://core/run/run_save.gd")
const MAIN_SCENE := "res://main/main.tscn"
const BATTLE_SCENE := "res://world/battle_system/battle_system.tscn"
const MAP_SCENE := "res://world/map/procedural_map.tscn"
const REST_SCENE := "res://interface/rest_screen.tscn"
const EVENT_SCENE := "res://interface/event_screen.tscn"
const SAVED_SCENES := {
	Context.MAP: MAP_SCENE, Context.COMBAT: BATTLE_SCENE, Context.REST: REST_SCENE,
	Context.EVENT: EVENT_SCENE, Context.REWARD: "res://interface/reward_screen.tscn"
}
const REST_HEAL_FRACTION := 0.40

enum Context { MAIN_MENU, MAP, COMBAT, SETUP, REWARD, FINISHED, REST, EVENT }
var current_context := Context.MAIN_MENU
var scenario_to_load := "" # Somente para abrir os cenários antigos no editor.
var map_to_load := "map_1"
var max_player_health := 80
var player_health := max_player_health
var level := 0
var world_index := 0
var world_cleared := false
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
var save_path := "user://incognita-run.save"
var _save_enabled := false
var _checkpoint: Dictionary = {}

func _ready() -> void:
	get_tree().scene_changed.connect(func(): _changing_scene = false)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and has_checkpoint():
		save_run()

func reset_run() -> void:
	_save_enabled = false
	_checkpoint.clear()
	player_health = max_player_health
	level = 0
	world_index = 0
	world_cleared = false
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
	_open_world(0)

func _open_world(index: int) -> void:
	world_index = index
	level = 0
	map_rows = Generator.generate(run_seed, world_index)
	available_nodes.clear()
	for node in map_rows[0]:
		available_nodes.append(node.id)

func world_info() -> Dictionary:
	return Generator.WORLDS[world_index]

func stage_text() -> String:
	if current_encounter.get("kind", "") == "final":
		return "Prova final • ENEM"
	var stages: int = world_info().stages
	return "%s • Etapa %d/%d" % [world_info().name, mini(level + 1, stages), stages]

func begin_run(difficult: bool, fixed_seed: int = -1) -> void:
	if _changing_scene:
		return
	prepare_run(difficult, fixed_seed)
	_save_enabled = true
	return_to_map()

func get_run_deck() -> Array:
	return Catalog.STARTER_DECK.duplicate() if run_deck.is_empty() else run_deck.duplicate()

func select_map_node(id: String) -> bool:
	if _changing_scene or current_context in [Context.REST, Context.EVENT] or reward_pending or run_complete or not available_nodes.has(id):
		return false
	var node := Generator.find_node(map_rows, id)
	if node.is_empty() or visited_nodes.has(id):
		return false
	current_node = node.duplicate(true)
	if node.kind == "rest":
		open_rest()
	elif node.kind == "event":
		_change_scene(EVENT_SCENE, Context.EVENT)
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
	var kind: String = current_encounter.get("kind", "")
	world_cleared = kind == "boss" and not current_node.is_empty()
	run_complete = kind == "final" or (boss and kind.is_empty())
	if kind != "final":
		_finish_node()
	var reward_seed := run_seed + victories * 7919 + int(current_encounter.get("seed", 0))
	pending_rewards = Catalog.reward_choices(reward_seed, 3, current_encounter.get("kind", "") == "elite")
	_record_checkpoint(Context.REWARD)

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
		finish_run_save()
		_change_scene("res://interface/run_complete.tscn", Context.FINISHED)
	elif world_cleared:
		world_cleared = false
		if world_index + 1 < Generator.WORLDS.size():
			_open_world(world_index + 1)
			return_to_map()
		else:
			current_encounter = Generator.encounter({"seed": run_seed + 314159, "world": world_index, "tier": 5, "kind": "final"})
			_change_scene(BATTLE_SCENE, Context.COMBAT)
	else:
		return_to_map()

func open_rest() -> void:
	_change_scene(REST_SCENE, Context.REST)

func rest_heal_amount() -> int:
	return int(max_player_health * REST_HEAL_FRACTION)

func complete_rest(remove_card_id: int = -1) -> bool:
	if _changing_scene or current_context != Context.REST:
		return false
	if remove_card_id == -1:
		player_health = mini(player_health + rest_heal_amount(), max_player_health)
	else:
		var index := run_deck.find(remove_card_id)
		if index < 0 or run_deck.size() <= 1:
			return false
		run_deck.remove_at(index)
	_finish_node()
	current_node.clear()
	return_to_map()
	return true

func resolve_event(choice: String) -> bool:
	if _changing_scene or current_context != Context.EVENT or current_node.get("kind", "") != "event":
		return false
	match choice:
		"combat":
			var node := current_node.duplicate(true)
			node.kind = "combat"
			current_encounter = Generator.encounter(node)
			_change_scene(BATTLE_SCENE, Context.COMBAT)
		"quiz":
			_finish_node()
			pending_rewards = Catalog.reward_choices(int(current_node.seed) + 151, 3)
			reward_pending = true
			_change_scene(SAVED_SCENES[Context.REWARD], Context.REWARD)
		"skip":
			_finish_node()
			current_node.clear()
			return_to_map()
		_:
			return false
	return true

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
	if has_checkpoint():
		save_run()
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
		_record_checkpoint(context)

func has_checkpoint() -> bool:
	return _save_enabled and not _checkpoint.is_empty()

func save_run() -> bool:
	return has_checkpoint() and Save.write(save_path, _checkpoint)

func has_saved_run() -> bool:
	return not _read_checkpoint().is_empty()

func _read_checkpoint() -> Dictionary:
	var data := Save.read(save_path)
	if data.is_empty() or not SAVED_SCENES.has(data.get("context")) or not data.get("world") is int:
		return {}
	if data.world < 0 or data.world >= Generator.WORLDS.size() or not data.get("seed") is int:
		return {}
	for key in ["level", "hp", "victories"]:
		if not data.get(key) is int:
			return {}
	for key in ["hard", "world_cleared", "run_complete"]:
		if not data.get(key) is bool:
			return {}
	for key in ["deck", "available", "visited", "rewards"]:
		if not data.get(key) is Array:
			return {}
	if not data.get("node") is Dictionary or not data.get("encounter") is Dictionary:
		return {}
	if data.deck.is_empty() or data.hp < 1 or data.hp > max_player_health:
		return {}
	for id in data.deck:
		if not id is int or Catalog.get_card(id).is_empty():
			return {}
	if data.context == Context.COMBAT and (not data.encounter.get("enemies") is Array or not data.encounter.get("boss") is bool):
		return {}
	if data.context == Context.REWARD and data.rewards.is_empty():
		return {}
	return data

func resume_run() -> bool:
	if _changing_scene:
		return false
	var data := _read_checkpoint()
	if data.is_empty():
		return false
	reset_run()
	_save_enabled = true
	run_seed = data.seed
	_open_world(data.world)
	level = data.level
	player_health = data.hp
	victories = data.victories
	hard_mode = data.hard
	world_cleared = data.world_cleared
	run_complete = data.run_complete
	run_deck = data.deck
	available_nodes = data.available
	visited_nodes = data.visited
	current_node = data.node
	current_encounter = data.encounter
	pending_rewards = data.rewards
	reward_pending = data.context == Context.REWARD
	_change_scene(SAVED_SCENES[data.context], data.context)
	return true

func finish_run_save() -> void:
	if has_checkpoint() and FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)
	_save_enabled = false
	_checkpoint.clear()

func _record_checkpoint(context: Context) -> void:
	if not _save_enabled or not SAVED_SCENES.has(context):
		return
	_checkpoint = {
		"version": Save.VERSION, "context": context, "seed": run_seed, "world": world_index,
		"level": level, "hp": player_health, "hard": hard_mode, "victories": victories,
		"deck": run_deck, "available": available_nodes, "visited": visited_nodes,
		"world_cleared": world_cleared, "run_complete": run_complete,
		"node": current_node, "encounter": current_encounter, "rewards": pending_rewards
	}.duplicate(true)
	save_run()

func _stop_audio(node: Node) -> void:
	if node is AudioStreamPlayer:
		node.stop()
	for child in node.get_children():
		_stop_audio(child)
