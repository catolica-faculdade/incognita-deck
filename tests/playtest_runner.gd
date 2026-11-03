extends "res://tests/test_runner.gd"
## Jogador heurístico para detectar runs inviáveis/travamentos; não prova balanceamento.

func _run() -> void:
	Engine.time_scale = 40.0
	var wins := 0
	for seed_value in [17, 42, 991, 12345]:
		GameManager.prepare_run(false, seed_value)
		await _show_scene("res://world/map/procedural_map.tscn")
		var rooms := 0
		var turns := 0
		var alive := true
		while not GameManager.run_complete and rooms < 7 and alive:
			var node_id := _choose_node()
			GameManager.select_map_node(node_id)
			await get_tree().scene_changed
			if GameManager.current_context == GameManager.Context.COMBAT:
				var battle := get_tree().current_scene
				var fight_turns := 0
				while battle.phase == battle.Phase.PLAYER and fight_turns < 50:
					_play_hand(battle)
					await battle.execute_turn_actions()
					fight_turns += 1
				turns += fight_turns
				alive = battle.player.health > 0
				if GameManager.reward_pending:
					var best: Dictionary = GameManager.pending_rewards[0]
					for data in GameManager.pending_rewards:
						if _reward_score(data) > _reward_score(best):
							best = data
					battle.get_node("RewardScreen")._choose(best.id)
					await get_tree().scene_changed
				elif alive:
					check(false, "combate não estagna por 50 turnos")
					alive = false
			rooms += 1
		if GameManager.run_complete:
			wins += 1
		print("PLAYTEST seed=%d salas=%d turnos=%d HP=%d venceu=%s" % [seed_value, rooms, turns, GameManager.player_health, GameManager.run_complete])
	await _clear_scene()
	print("PLAYTEST: %d/4 vitórias, %d falhas de execução" % [wins, failures])
	get_tree().quit(0 if failures == 0 else 1)

func _choose_node() -> String:
	var best: Dictionary = {}
	var score := -INF
	for id in GameManager.available_nodes:
		var node: Dictionary = Generator.find_node(GameManager.map_rows, id)
		var value := -float(node.tier)
		if node.kind == "rest":
			value += 10.0 if GameManager.player_health < 65 else -5.0
		if best.is_empty() or value > score:
			best = node
			score = value
	return best.id

func _play_hand(battle: Node) -> void:
	var hand: Array = battle.combat_ui.card_container.get_children()
	var best_mask := 0
	var best_score := -INF
	for mask in range(1 << hand.size()):
		var data: Array = []
		var cost := 0
		for i in range(hand.size()):
			if mask & (1 << i):
				data.append(hand[i].card_data)
				cost += int(hand[i].card_data.energy_cost)
		if cost > 5:
			continue
		var value := _score_play(battle, data) - cost * 0.01
		if value > best_score:
			best_score = value
			best_mask = mask
	for i in range(hand.size()):
		if best_mask & (1 << i):
			battle.combat_ui._on_card_played(hand[i])

func _score_play(battle: Node, cards: Array) -> float:
	var formula = Formula.new()
	formula.rebuild(cards)
	var effects: Dictionary = Effects.aggregate(cards)
	var points := PackedVector2Array()
	for point in formula.sample():
		points.append(battle.trajectory.to_global(point))
	var value := minf(effects.heal, 80 - battle.player.health) * 2.0
	value += effects.strength * 5.0
	value += mini(battle.player.poison_amount * 2, 15) if effects.cleanse > 0 else 0
	var incoming := 0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not enemy.check_is_alive():
			continue
		var hits := Targeting.hits(points, enemy.global_position, battle.lock_distance)
		var damage: int = battle.player.attack_damage(battle.player_damage + int(effects.damage))
		if enemy.vulnerable > 0 or effects.vulnerable > 0:
			damage = int(damage * 1.5)
		if effects.pierce == 0:
			damage = maxi(damage - enemy.shield, 0)
		if hits:
			value += mini(enemy.health, damage) * 1.8
			value += mini(enemy.health - mini(enemy.health, damage), effects.poison * 2) * 1.2
			if damage + enemy.poison_amount >= enemy.health:
				value += 20.0
				continue
		match enemy.planned_action:
			"attack", "drain": incoming += enemy.base_damage + enemy.strength
			"heavy": incoming += (enemy.base_damage + enemy.strength) * 2
			"poison": value += effects.cleanse * 0.5
	value += mini(effects.shield, incoming) * 1.5
	if incoming > 0:
		value += effects.thorns * 1.5
	return value

func _reward_score(card: Dictionary) -> float:
	var weights: Dictionary = {1:15,2:4,3:2,4:1,5:12,7:6,16:12,17:12,18:12,19:8,20:16,21:14,22:15,23:16,24:14,25:12,26:10,27:25,28:20,29:4,30:5}
	return float(weights.get(int(card.id), 3))
