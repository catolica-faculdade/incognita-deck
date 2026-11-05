extends Node

const Selection = preload("res://core/combat/card_selection.gd")
const Formula = preload("res://core/combat/trajectory_formula.gd")
const Targeting = preload("res://core/combat/trajectory_targeting.gd")
const Effects = preload("res://core/combat/card_effects.gd")
const Deck = preload("res://core/cards/combat_deck.gd")
const Catalog = preload("res://card/card_database.gd")
const Generator = preload("res://core/run/run_generator.gd")
const Builder = preload("res://world/combat/encounter_builder.gd")
var checks := 0
var failures := 0

func _ready() -> void:
	get_tree().current_scene = null
	_run.call_deferred()

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FALHOU: " + message)

func _run() -> void:
	Engine.time_scale = 30.0
	_resources("res://")
	_test_selection_and_formula()
	_test_deck()
	_test_generation()
	await _test_cards()
	await _test_legacy_scenes()
	await _test_generated_enemies()
	await _test_pointer_input()
	await _test_symbol_hud()
	await _test_hover_and_pause()
	await _test_enemy_names()
	await _test_deck_viewer()
	await _test_effect_resolution()
	await _test_status_and_intents()
	await _test_freed_enemy_during_turn()
	await _test_rewards()
	await _test_navigation()
	await _test_full_run()
	await _clear_scene()
	print("REGRESSAO: %d verificações, %d falhas" % [checks, failures])
	get_tree().quit(0 if failures == 0 else 1)

func _resources(directory: String) -> void:
	for file in DirAccess.get_files_at(directory):
		if file.ends_with(".gd") or file.ends_with(".tscn"):
			var resource = load(directory.path_join(file))
			check(resource != null, "carrega " + directory.path_join(file))
			if resource is Script:
				check(resource.can_instantiate(), "script compila: " + directory.path_join(file))
	for child in DirAccess.get_directories_at(directory):
		if not child.begins_with(".") and child != "addons":
			_resources(directory.path_join(child))

func _test_selection_and_formula() -> void:
	var model = Selection.new(5)
	check(not model.try_play(1, Catalog.get_card(5)), "bloqueado fora do turno")
	model.enabled = true
	check(model.try_play(1, Catalog.get_card(5)) and model.current_energy == 3, "debita energia")
	check(not model.try_play(1, Catalog.get_card(5)), "não duplica seleção")
	check(not model.try_remove(900), "não cria reembolso")
	model.try_play(2, Catalog.get_card(5))
	check(not model.try_play(3, Catalog.get_card(5)), "rejeita custo excessivo")
	model.enabled = false
	check(not model.try_remove(1) and not model.clear(), "protege limpeza e remoção")
	model.enabled = true
	check(model.try_remove(1) and model.current_energy == 3, "devolve custo exato")
	model.clear()
	check(model.current_energy == 5 and model.cards_data().is_empty(), "limpa seleção")
	var formula = Formula.new()
	formula.rebuild([Catalog.get_card(1), Catalog.get_card(2)])
	check(formula.sample()[-1].is_equal_approx(Vector2(975, -150)), "composição linear")
	formula.rebuild([Catalog.get_card(1), Catalog.get_card(3), Catalog.get_card(4)])
	check(formula.sample()[-1].is_equal_approx(Vector2(600, 0)), "parábolas se cancelam")
	formula.rebuild([Catalog.get_card(5)])
	check(formula.sample().size() == 41 and "sen" in formula.equation_text(), "onda matemática")
	formula.rebuild([{"type":"special","special_type":"wave","amplitude":1.0,"frequency":1.0,"length":4.0}, {"type":"linear","x":8.0,"y":0.0}])
	check(formula.sample(1.0, 8)[1].is_equal_approx(Vector2(1, -1)), "avanço não muda frequência escrita na carta")
	formula.rebuild([{"type":"special","special_type":"wave","amplitude":1.0,"frequency":1.0,"length":4.0}, {"type":"special","special_type":"wave","amplitude":1.0,"frequency":1.0,"length":8.0}])
	check(is_equal_approx(formula.sample(1.0, 8)[1].y, -1.0 - sqrt(0.5)), "ondas somam funções sem inventar frequência")
	formula.rebuild([Catalog.get_card(17), Catalog.get_card(18)])
	check(not formula.has_cards and formula.sample().size() == 1, "efeitos não inventam trajetória")
	var line := PackedVector2Array([Vector2.ZERO, Vector2(100, 0)])
	check(Targeting.hits(line, Vector2(50, 65), 65), "raio inclusivo")
	check(not Targeting.hits(line, Vector2(50, 66), 65), "fora do raio")
	var effects := Effects.aggregate([Catalog.get_card(16), Catalog.get_card(17), Catalog.get_card(18), Catalog.get_card(28)])
	check(effects.heal == 11 and effects.shield == 15 and effects.poison == 4, "agrega efeitos compostos")

func _test_deck() -> void:
	var deck = Deck.new()
	var other = Deck.new()
	deck.setup(Catalog.STARTER_DECK, 17)
	other.setup(Catalog.STARTER_DECK, 17)
	var hand: Array = deck.draw(5)
	check(hand == other.draw(5), "compra reproduzível")
	check(deck.draw_pile.size() + hand.size() == Catalog.STARTER_DECK.size(), "conserva cartas na compra")
	deck.discard(hand)
	check(deck.discard_pile.size() == 5, "descarte possui cartas reais")
	var rest: Array = deck.draw(12)
	check(rest.size() == 12 and deck.draw_pile.is_empty() and deck.discard_pile.is_empty(), "recicla descarte apenas quando compra esgota")
	check(deck.draw(5).is_empty(), "não cria cartas com pilhas vazias")
	deck.setup([30], 10)
	check(deck.draw(1)[0].id == 30, "carta de recompensa entra na compra")

func _test_generation() -> void:
	check(Generator.generate(17) == Generator.generate(17), "mapa estável por semente")
	check(Generator.generate(17) != Generator.generate(18), "sementes criam mapas diferentes")
	var seen_archetypes: Dictionary = {}
	for seed_value in range(60):
		var rows: Array = Generator.generate(seed_value)
		check(rows.size() == 7 and rows[-1].size() == 1 and rows[-1][0].kind == "boss", "chefe alcançável no final")
		var reachable: Array = []
		for node in rows[0]:
			reachable.append(node.id)
		for row in rows:
			var following: Array = []
			for node in row:
				check(reachable.has(node.id), "nó possui rota de entrada")
				check(node.tier >= 1 and node.tier <= 5, "tier limitado")
				if node.row < 6:
					check(not node.next.is_empty(), "rota sem beco sem saída")
				for next_id in node.next:
					var next: Dictionary = Generator.find_node(rows, next_id)
					check(int(next.row) == int(node.row) + 1, "rota avança uma etapa")
					if not following.has(next_id):
						following.append(next_id)
				if node.kind != "rest":
					var encounter: Dictionary = Generator.encounter(node)
					check(encounter == Generator.encounter(node), "encontro não rerrola")
					check(encounter.enemies.size() >= 2 and encounter.enemies.size() <= 4, "composição limitada")
					for enemy in encounter.enemies:
						seen_archetypes[enemy.archetype] = true
						check(Builder.ENEMY_SCENES.has(enemy.archetype), "arquétipo existe")
			reachable = following
	check(seen_archetypes.size() == 8, "geração usa oito arquétipos")

func _clear_scene() -> void:
	get_tree().paused = false
	var scene := get_tree().current_scene
	if is_instance_valid(scene):
		_stop_audio(scene)
		scene.queue_free()
		get_tree().current_scene = null
		await get_tree().process_frame
	await get_tree().process_frame

func _stop_audio(node: Node) -> void:
	if node is AudioStreamPlayer:
		node.stop()
	for child in node.get_children():
		_stop_audio(child)

func _show_scene(path: String) -> Node:
	await _clear_scene()
	var scene = load(path).instantiate()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	await get_tree().process_frame
	await get_tree().process_frame
	return scene

func _battle(tier: int = 1, hard: bool = false, archetypes: Array = ["cube"]) -> Node:
	GameManager.prepare_run(hard, 17)
	var spec: Dictionary = Generator.encounter({"seed":101, "tier":tier, "kind":"combat"})
	spec.enemies.clear()
	for i in range(archetypes.size()):
		spec.enemies.append({"archetype":archetypes[i],"position":Vector2(260 + i * 180, -240),"tier":tier,"seed":30 + i})
	GameManager.current_encounter = spec
	return await _show_scene("res://world/battle_system/battle_system.tscn")

func _set_hand(ui: Node, ids: Array) -> void:
	ui.selection.enabled = true
	ui.return_all_cards_to_hand()
	for card in ui.card_container.get_children():
		ui.card_container.remove_child(card)
		card.queue_free()
	ui.deck.setup(ids, 1)
	ui.selection.start_round()
	ui._draw_hand()
	ui._refresh_cards()
	await get_tree().process_frame
	await get_tree().process_frame

func _card(ui: Node, id: int) -> Control:
	for card in ui.card_container.get_children():
		if card.card_data.id == id:
			return card
	return null

func _test_cards() -> void:
	var battle = await _battle()
	var ids := {}
	for data in Catalog.CARDS:
		check(not ids.has(data.id), "ID único")
		ids[data.id] = true
		check(data.energy_cost >= 0 and data.energy_cost <= 5, "custo cabe na energia")
		check(not Catalog.math_text(data).is_empty(), "conta visível em " + data.name)
		var card = preload("res://card/card.tscn").instantiate()
		battle.combat_ui.card_container.add_child(card)
		card.setup(data, false)
		check(card.cost_label.text == str(data.energy_cost) and card.symbol.visible, "custo e ilustração normal")
		check(card.cost_badge.position.y < 0 and card.cost_badge.get_rect().end.x > card.size.x, "custo sobre o canto externo")
		for label in [card.title, card.value]:
			var font: Font = label.get_theme_font("font")
			for line in label.text.split("\n"):
				check(font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, label.get_theme_font_size("font_size")).x <= label.size.x, "texto cabe em " + data.name)
		card.set_hard_mode(true)
		check(not card.symbol.visible and not card.texture_rect.visible and card.value.visible, "difícil remove toda ilustração da carta")
		check(card.cost_label.text == str(data.energy_cost), "difícil preserva custo")
		card.queue_free()
	check(Catalog.CARDS.size() == 30, "30 cartas no catálogo")

func _test_legacy_scenes() -> void:
	for filename in DirAccess.get_files_at("res://world/combat"):
		if filename.ends_with(".tscn"):
			GameManager.reset_run()
			GameManager.scenario_to_load = "res://world/combat/" + filename
			var battle = await _show_scene("res://world/battle_system/battle_system.tscn")
			check(battle.phase == battle.Phase.PLAYER, "cenário antigo ainda abre: " + filename)

func _test_generated_enemies() -> void:
	for archetype in Builder.ENEMY_SCENES:
		var battle = await _battle(3, false, [archetype])
		var enemy = get_tree().get_nodes_in_group("enemies")[0]
		var base_hp: int = {"cube":28,"ghost":22,"calculator":24,"slime":20,"teacher":65,"sentinel":34,"alchemist":26,"leech":25}[archetype]
		var base_attack: int = {"cube":8,"ghost":6,"calculator":7,"slime":5,"teacher":8,"sentinel":7,"alchemist":5,"leech":7}[archetype]
		check(enemy.max_health == int(base_hp * 1.3) and enemy.base_damage == base_attack + 2, "perfil e tier não herdam valores de outro arquétipo")
		check(battle.scenario_container.name == "GeneratedEncounter", "não carrega fase pronta")
		check(not enemy.intent_text().is_empty(), "inimigo anuncia intenção: " + archetype)
		enemy.health = 1
		await enemy.heal(3)
		check(enemy.health == 4, "cura externa uniforme")
		await enemy.apply_shield(6)
		await enemy.take_damage(4)
		check(enemy.health == 4 and enemy.shield == 2, "escudo absorve")
		await enemy.take_damage(1, true)
		check(enemy.health == 3 and enemy.shield == 2, "perfuração ignora escudo")
		await enemy.take_damage(10000, true)
		await get_tree().process_frame
		check(not is_instance_valid(enemy), "morte libera inimigo")
	GameManager.prepare_run(false, 17)
	GameManager.level = 6
	GameManager.current_encounter = Generator.encounter({"seed":17, "tier":5, "kind":"boss"})
	var boss_battle = await _show_scene("res://world/battle_system/battle_system.tscn")
	check(boss_battle.is_boss_fight and get_tree().get_nodes_in_group("enemies").size() == 3, "chefe procedural tem composição própria")
	await _capture("new-enemies.png")

func _capture(filename: String) -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-dir=") and DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			check(get_viewport().get_texture().get_image().save_png(argument.trim_prefix("--capture-dir=").path_join(filename)) == OK, "captura " + filename)

func _mouse_move(point: Vector2, buttons: int = 0) -> void:
	var event := InputEventMouseMotion.new()
	event.position = point
	event.global_position = point
	event.button_mask = buttons
	get_viewport().push_input(event, true)
	await get_tree().process_frame

func _mouse_button(point: Vector2, down: bool) -> void:
	var event := InputEventMouseButton.new()
	event.position = point
	event.global_position = point
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = down
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if down else 0
	get_viewport().push_input(event, true)
	await get_tree().process_frame

func _test_pointer_input() -> void:
	var battle = await _battle()
	var ui = battle.combat_ui
	await _set_hand(ui, [1, 2, 5, 16, 17])
	await _capture("new-combat-normal.png")
	var card = _card(ui, 1)
	var origin: Vector2 = card.get_global_rect().get_center()
	var destination: Vector2 = ui.drop_zone.get_global_rect().position + Vector2(12, 12)
	await _mouse_move(origin)
	await _mouse_button(origin, true)
	check(card.dragging, "mouse inicia arraste")
	await _mouse_move(destination, MOUSE_BUTTON_MASK_LEFT)
	await _mouse_button(destination, false)
	check(card.is_played and ui.selection.current_energy == 4, "arraste seleciona e debita")
	await get_tree().process_frame
	check(card.size.is_equal_approx(Vector2(128, 196)) and card.texture_rect.visible and card.symbol.visible and card.target_label.visible, "carta preparada permanece inteira")
	await _capture("refined-combat.png")
	await _mouse_move(card.get_global_rect().get_center())
	await _mouse_button(card.get_global_rect().get_center(), true)
	await _mouse_move(origin, MOUSE_BUTTON_MASK_LEFT)
	await _mouse_button(origin, false)
	check(not card.is_played and ui.selection.current_energy == 5, "arraste devolve e reembolsa")
	ui._on_card_played(card)
	ui.return_all_cards_to_hand()
	check(ui.selection.current_energy == 5, "limpar reembolsa")
	battle = await _battle(1, true)
	await _set_hand(battle.combat_ui, [1, 2, 5, 16, 17])
	await _capture("new-combat-hard.png")
	for item in battle.combat_ui.card_container.get_children():
		check(not item.symbol.visible and item.value.visible, "mão difícil sem desenhos")

func _wait_turn(battle: Node) -> void:
	var frames := 0
	while battle.phase != battle.Phase.PLAYER and battle.phase != battle.Phase.FINISHED:
		await get_tree().process_frame
		frames += 1
		if frames > 3000:
			check(false, "turno termina sem travar")
			return

func _test_symbol_hud() -> void:
	var battle = await _battle()
	var ui = battle.combat_ui
	battle.player.health = 61
	battle.player.apply_effects(Effects.aggregate([Catalog.get_card(17), Catalog.get_card(25)]))
	battle.player.receive_poison(3)
	check(ui.player_interface.health_label.text == "HP: 61/80", "HUD de símbolos mostra HP")
	check(ui.player_interface.shield_label.text == "Escudo: 11", "HUD de símbolos acompanha escudo")
	check(ui.player_interface.poison_label.text == "Veneno: 3", "HUD de símbolos acompanha veneno")
	check(ui.player_interface.thorns_label.text == "Espinhos: 4", "HUD acompanha efeito de espinhos")
	check(ui.player_interface.icons.thorns.texture.resource_path == "res://assets/interface/thorns_icon.png", "HUD usa o ícone de espinhos gerado")
	await _set_hand(ui, [1, 2, 3, 16, 17])
	check(ui.energy_texture.texture.atlas.resource_path == "res://energy/energy_5.png", "contador usa imagem antiga de energia cheia")
	var hand: Array = ui.card_container.get_children()
	for i in range(hand.size()):
		ui._on_card_played(hand[i])
		check(ui.energy_texture.texture.atlas.resource_path == "res://energy/energy_%d.png" % (4 - i), "contador visual acompanha custo")
	ui.return_all_cards_to_hand()
	check(ui.energy_texture.texture.atlas.resource_path == "res://energy/energy_5.png", "reembolso restaura contador visual")
	await _set_hand(ui, [1, 2, 5, 17, 25])
	await _capture("restored-status-hud.png")

func _test_hover_and_pause() -> void:
	var battle = await _battle(3, true)
	var enemy = get_tree().get_nodes_in_group("enemies")[0]
	enemy.health = 5
	enemy.strength = 3
	enemy.shield = 4
	enemy._refresh_hud()
	check(enemy.hud.health_bar.value == 5 and enemy.hud.health_bar.max_value == enemy.max_health, "barra acompanha vida real")
	check(enemy.hud.health_label.text == "5/%d" % enemy.max_health and enemy.hud.shield_label.text == "4", "hover mostra totais de vida e escudo")
	check(enemy.hud.name_label.text == "Cubo", "hover mostra somente nome sem papel")
	check(enemy.hud.hover_info.get_child(1).size.is_equal_approx(Vector2(22, 22)), "símbolo de escudo mantém tamanho do hover")
	await _mouse_move(enemy.hud.body_hover.get_global_transform_with_canvas() * (enemy.hud.body_hover.size * 0.5))
	await get_tree().process_frame
	check(enemy.hud.hover_info.visible, "hover do sprite mostra nome e valores")
	await get_tree().create_timer(24.0).timeout
	await _capture("enemy-hover.png")
	await _mouse_move(enemy.hud.health_bar.get_global_transform_with_canvas() * (enemy.hud.health_bar.size * 0.5))
	await get_tree().process_frame
	check(enemy.hud.hover_info.visible, "hover da barra mostra nome e valores")
	await get_tree().create_timer(24.0).timeout
	await _capture("enemy-health-hover.png")
	await _mouse_move(Vector2(1100, 150))
	await get_tree().process_frame
	check(not enemy.hud.hover_info.visible, "sair do inimigo esconde informações")
	check(not enemy.hud.poison_marker.visible, "sem veneno não mostra marcador")
	enemy.receive_poison(3)
	check(enemy.hud.poison_marker.visible and enemy.hud.poison_label.text == "3", "marcador mostra veneno aplicado sem hover")
	enemy.receive_poison(2)
	check(enemy.hud.poison_label.text == "5", "marcador acompanha acúmulo de veneno")
	await _capture("enemy-poison-marker.png")
	enemy.poison_amount = 0
	enemy._refresh_hud()
	check(not enemy.hud.poison_marker.visible, "fim do veneno esconde marcador")
	PauseMenu.pause()
	check(PauseMenu.run_info_label.visible and "Turno 1" in PauseMenu.run_info_label.text and "Etapa 1/7" in PauseMenu.run_info_label.text and "Desafiador" in PauseMenu.run_info_label.text and "Modo Difícil" in PauseMenu.run_info_label.text, "pause reúne turno, etapa, dificuldade e modo")
	await _capture("pause-run-info.png")
	PauseMenu.resume()
	battle = await _battle()
	GameManager.pending_rewards = [Catalog.get_card(5), Catalog.get_card(27), Catalog.get_card(28)]
	battle.add_child(preload("res://interface/reward_screen.tscn").instantiate())
	await get_tree().process_frame
	await get_tree().process_frame
	await _capture("refined-rewards.png")

func _test_enemy_names() -> void:
	for archetype in Builder.ENEMY_SCENES:
		var battle = await _battle(1, false, [archetype, archetype, "cube" if archetype != "cube" else "ghost"])
		var enemies: Array = get_tree().get_nodes_in_group("enemies")
		var base_name: String = enemies[0].display_name
		check(enemies[0].hud.name_label.text == base_name + " 1" and enemies[1].hud.name_label.text == base_name + " 2", "numeração de duplicatas: " + archetype)
		check(enemies[2].hud.name_label.text == enemies[2].display_name, "inimigo único sem número")
		check(enemies[0].hud.shield_label.text == "0", "escudo zero também informado")
		if archetype == "ghost":
			await _mouse_move(enemies[0].hud.body_hover.get_global_transform_with_canvas() * (enemies[0].hud.body_hover.size * 0.5))
			await get_tree().process_frame
			await _capture("simplified-enemy-hover.png")
		enemies[0].remove_from_group("enemies")
		enemies[0].queue_free()
		await get_tree().process_frame
		enemies[1]._refresh_hud()
		check(enemies[1].hud.name_label.text == base_name + " 2", "nome estável após derrota de duplicata")

func _test_deck_viewer() -> void:
	var battle = await _battle(1, true)
	var viewer = preload("res://interface/deck_viewer.gd").new()
	battle.add_child(viewer)
	check(get_tree().paused and viewer.card_views.size() == GameManager.run_deck.size(), "visualizador mostra baralho completo e pausa")
	for card in viewer.card_views:
		check(not card.symbol.visible and not card.texture_rect.visible, "visualizador respeita modo difícil")
	viewer._close()
	check(not get_tree().paused, "fechar baralho restaura combate")

func _test_effect_resolution() -> void:
	var battle = await _battle()
	var ui = battle.combat_ui
	var enemy = get_tree().get_nodes_in_group("enemies")[0]
	enemy.max_health = 100
	enemy.health = 100
	enemy.idle_height = 0
	enemy.planned_action = "defend"
	battle.player.health = 40
	await _set_hand(ui, [1, 16, 17, 18, 19])
	for card in ui.card_container.get_children():
		ui._on_card_played(card)
	check(battle.player.health == 40 and battle.player.shield_amount == 0, "seleção não aplica efeitos antecipados")
	ui.return_all_cards_to_hand()
	check(battle.player.health == 40 and ui.selection.current_energy == 5, "cancelar não permite cura gratuita")
	for card in ui.card_container.get_children():
		ui._on_card_played(card)
	battle.execute_turn_actions()
	check(not ui.selection.enabled and battle.player.health == 45 and battle.player.shield_amount == 7, "confirmar aplica efeitos e bloqueia entrada")
	battle.execute_turn_actions()
	await _wait_turn(battle)
	check(enemy.health == 73 and enemy.poison_amount == 3, "dano extra e veneno atingem alvo")
	check(ui.turn_count == 2 and ui.selection.current_energy == 5, "clique duplo não duplica turno")
	check(ui.card_container.get_child_count() == 5 and ui.played_container.get_child_count() == 0, "descarte e recompra de mão")
	check(battle.player.shield_amount == 0, "bloqueio expira no próximo turno")
	await _set_hand(ui, [17, 18])
	ui._on_card_played(_card(ui, 18))
	check(battle.current_enemies.is_empty(), "veneno sem trajetória não escolhe alvo")

func _test_status_and_intents() -> void:
	var battle = await _battle(1, false, ["leech"])
	var player = battle.player
	player.health = 40
	player.apply_shield(8)
	await player.take_damage(5)
	check(player.health == 40 and player.shield_amount == 3, "bloqueio do jogador funciona")
	player.receive_poison(4)
	await player.begin_turn()
	check(player.health == 36 and player.poison_amount == 3, "veneno ignora bloqueio e perde uma carga")
	player.apply_effects(Effects.aggregate([Catalog.get_card(20)]))
	check(player.poison_amount == 0 and player.health == 39, "antídoto limpa e cura")
	player.receive_weak(2)
	check(player.attack_damage(20) == 15, "fraqueza reduz dano")
	player.finish_turn()
	check(player.weak == 1, "fraqueza conta turnos próprios")
	var enemy = get_tree().get_nodes_in_group("enemies")[0]
	enemy.health = 10
	enemy.planned_action = "drain"
	player.thorns = 4
	await enemy.take_turn()
	check(enemy.health > 6 and player.health < 39, "drenagem cura após dano e espinhos reagem")
	check(enemy.planned_action == enemy.choose_action(), "intenção já define próxima ação")
	enemy.shield = 50
	enemy.receive_vulnerable(2)
	var hp_before: int = enemy.health
	await enemy.take_damage(2, true)
	check(enemy.health == hp_before - 3 and enemy.shield == 50, "vulnerabilidade e perfuração combinam")
	player.health = 1
	player.receive_poison(20)
	await battle._start_player_turn(true)
	check(battle.phase == battle.Phase.FINISHED and player.health == 0, "veneno letal produz derrota")
	check(battle.get_node_or_null("GameOverScreen") != null, "derrota tem tela própria")

func _test_rewards() -> void:
	var battle = await _battle(1, true)
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.health = 0
	await battle.execute_turn_actions()
	check(GameManager.reward_pending and GameManager.pending_rewards.size() == 3, "vitória sorteia três cartas")
	var offers: Array = GameManager.pending_rewards.duplicate(true)
	check(offers[0].id != offers[1].id and offers[1].id != offers[2].id and offers[0].id != offers[2].id, "oferta sem duplicatas")
	await battle._finish_if_needed()
	check(GameManager.pending_rewards == offers and GameManager.victories == 1, "resultado não rerrola nem duplica recompensa")
	check(get_tree().paused and battle.get_node_or_null("RewardScreen") != null, "recompensa pausa combate")
	for card in battle.get_node("RewardScreen").offered_cards:
		check(not card.symbol.visible and not card.texture_rect.visible, "recompensa respeita modo difícil")
	PauseMenu.pause()
	check(not PauseMenu.overlay.visible, "pausa não cobre recompensa")
	await _capture("new-rewards.png")
	var size_before: int = GameManager.run_deck.size()
	check(not GameManager.claim_reward(9999), "não aceita carta fora da oferta")
	check(GameManager.claim_reward(offers[0].id), "aceita escolha oferecida")
	check(GameManager.run_deck.size() == size_before + 1, "uma carta incorporada ao baralho")
	check(not GameManager.claim_reward(offers[1].id), "não aceita segunda recompensa")
	GameManager.reset_run()
	check(GameManager.run_deck.is_empty() and not GameManager.hard_mode, "nova run não herda cartas nem modo")

func _test_freed_enemy_during_turn() -> void:
	var battle = await _battle(1, false, ["cube", "cube"])
	var enemies: Array = get_tree().get_nodes_in_group("enemies")
	enemies[0].position.y = -355
	enemies[0].start_position = enemies[0].position
	enemies[0].idle_height = 0
	enemies[0].planned_action = "defend"
	enemies[1].health = 1
	enemies[1].idle_height = 0
	await _set_hand(battle.combat_ui, [1])
	battle.combat_ui._on_card_played(_card(battle.combat_ui, 1))
	await battle.execute_turn_actions()
	check(battle.phase == battle.Phase.PLAYER, "corpse liberado durante outro await não trava turno")
	check(get_tree().get_nodes_in_group("enemies").size() == 1, "inimigo eliminado não age")

func _test_navigation() -> void:
	var menu = await _show_scene("res://main/main.tscn")
	var viewport_center := get_viewport().get_visible_rect().get_center().x
	check(is_equal_approx(menu.start_button.get_global_rect().get_center().x, viewport_center), "menu começar centralizado")
	check(is_equal_approx(menu.leave_button.get_global_rect().get_center().x, viewport_center), "menu sair centralizado")
	check(menu.start_button.get_global_rect().position.y >= menu.logo.get_global_rect().end.y, "logo não sobrepõe começar")
	check(menu.leave_button.get_global_rect().position.y >= menu.start_button.get_global_rect().end.y, "botões do menu não se sobrepõem")
	check(menu.get_node("DoodleBackground").get_rect().size.is_equal_approx(get_viewport().get_visible_rect().size), "menu cobre viewport sem margens cinzas")
	await _capture("doodle-main-menu.png")
	menu.start_button.pressed.emit()
	await get_tree().scene_changed
	check(GameManager.current_context == GameManager.Context.SETUP, "pergunta modo antes de cada run")
	await _capture("new-run-setup.png")
	get_tree().current_scene.hard_button.pressed.emit()
	await get_tree().scene_changed
	check(GameManager.hard_mode and GameManager.current_context == GameManager.Context.MAP, "difícil abre mapa")
	check(get_tree().current_scene.node_buttons.size() == 19, "mapa renderiza todos os nós")
	var background = get_tree().current_scene.get_node("DoodleBackground")
	check(background.texture.resource_path == "res://assets/backgrounds/background_map.png", "mapa usa background original")
	check(background.get_rect().size.is_equal_approx(get_viewport().get_visible_rect().size), "background do mapa preenche viewport")
	await _capture("new-procedural-map.png")
	check(not GameManager.select_map_node("6:0"), "não pula direto ao chefe")
	var map_before: Array = GameManager.map_rows.duplicate(true)
	var node_id: String = GameManager.available_nodes[0]
	check(not get_tree().current_scene.node_buttons[node_id].disabled, "nó disponível tem botão ativo")
	get_tree().current_scene.node_buttons[node_id].pressed.emit()
	await get_tree().scene_changed
	check(get_tree().current_scene.scenario_container.name == "GeneratedEncounter", "mapa usa combate procedural")
	check(GameManager.map_rows == map_before, "entrar no combate não rerrola mapa")
	GameManager.return_to_menu()
	await get_tree().scene_changed
	check(not GameManager.hard_mode and GameManager.player_health == 80, "menu encerra estado da run")

func _test_full_run() -> void:
	await _show_scene("res://interface/run_setup.tscn")
	GameManager.begin_run(false, 991)
	await get_tree().scene_changed
	var steps := 0
	while not GameManager.run_complete and steps < 8:
		var id: String = GameManager.available_nodes[0]
		check(GameManager.select_map_node(id), "run completa escolhe próximo nó")
		await get_tree().scene_changed
		if GameManager.current_context == GameManager.Context.COMBAT:
			var battle := get_tree().current_scene
			for enemy in get_tree().get_nodes_in_group("enemies"):
				enemy.health = 0
			await battle.execute_turn_actions()
			var screen = battle.get_node("RewardScreen")
			screen._choose(-1)
			await get_tree().scene_changed
		steps += 1
	check(steps == 7 and GameManager.run_complete, "sete etapas alcançam conclusão")
	check(GameManager.current_context == GameManager.Context.FINISHED, "chefe leva ao resumo após recompensa")
	check(GameManager.visited_nodes.size() == 7, "cada etapa concluída uma vez")
	await _capture("new-run-complete.png")
	GameManager.start_run()
	await get_tree().scene_changed
	check(GameManager.current_context == GameManager.Context.SETUP, "repetir run volta a perguntar dificuldade")
