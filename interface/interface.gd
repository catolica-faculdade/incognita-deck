extends CanvasLayer

signal end_turn_requested
signal selection_changed(cards: Array)
signal card_hover_changed(hovered: bool)

const Selection = preload("res://core/combat/card_selection.gd")
const Deck = preload("res://core/cards/combat_deck.gd")
const Effects = preload("res://core/combat/card_effects.gd")
const Style = preload("res://interface/ui_style.gd")
const CARD_SCENE = preload("res://card/card.tscn")
const PLAYER_HUD = preload("res://world/player/player_interface.tscn")
const CARDS_PER_TURN := 6
const HAND_LIMIT := 12
const DISCARD_LIMIT := 2
const ENERGY_IMAGES = [
	preload("res://energy/energy_0.png"), preload("res://energy/energy_1.png"),
	preload("res://energy/energy_2.png"), preload("res://energy/energy_3.png"),
	preload("res://energy/energy_4.png"), preload("res://energy/energy_5.png")
]
var selection = Selection.new(5)
var deck = Deck.new()
var turn_count := 0
var choosing_discards := false
var selected_discards: Array[Control] = []
var card_container: HBoxContainer
var played_container: HBoxContainer
var equation_label: Label
var energy_texture: TextureRect
var energy_icons: Array[AtlasTexture] = []
var player_interface: Control
var buff_label: Label
var deck_label: Label
var effect_label: Label
var end_turn_button: Button
var confirm_discard_button: Button
var clear_button: Button
var drop_zone: Control
var root: Control
var hand_panel: Panel

func _ready() -> void:
	_build_ui()
	deck.setup(GameManager.get_run_deck(), GameManager.run_seed + int(GameManager.current_encounter.get("seed", 101)))
	_draw_hand()
	_refresh_cards()
	get_viewport().size_changed.connect(_layout)
	_layout()

func _build_ui() -> void:
	root = Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Restaura o painel de símbolos e libera o campo da faixa de papel.
	player_interface = PLAYER_HUD.instantiate()
	root.add_child(player_interface)
	equation_label = Style.readable_label("y = 0", 22)
	equation_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	equation_label.max_lines_visible = 3
	equation_label.clip_text = true
	root.add_child(equation_label)
	buff_label = Style.readable_label("", 16)
	root.add_child(buff_label)
	drop_zone = Control.new()
	drop_zone.name = "DropZone"
	drop_zone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(drop_zone)
	played_container = HBoxContainer.new()
	played_container.alignment = BoxContainer.ALIGNMENT_CENTER
	played_container.add_theme_constant_override("separation", 8)
	played_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(played_container)
	played_container.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	effect_label = Style.label("Arraste as cartas para esta área", 15)
	effect_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(effect_label)
	hand_panel = Panel.new()
	hand_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	hand_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(hand_panel)
	card_container = HBoxContainer.new()
	card_container.alignment = BoxContainer.ALIGNMENT_CENTER
	card_container.add_theme_constant_override("separation", 8)
	card_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hand_panel.add_child(card_container)
	energy_texture = TextureRect.new()
	energy_texture.name = "EnergyTexture"
	energy_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	energy_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	energy_texture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	root.add_child(energy_texture)
	for image in ENERGY_IMAGES:
		var atlas := AtlasTexture.new()
		atlas.atlas = image
		atlas.region = Rect2(710, 280, 500, 520)
		energy_icons.append(atlas)
	deck_label = Style.label("", 14)
	root.add_child(deck_label)
	clear_button = Style.illustrated_button(preload("res://assets/button_trajectory.png"), return_all_cards_to_hand)
	clear_button.tooltip_text = "Limpar trajetória"
	root.add_child(clear_button)
	end_turn_button = Style.illustrated_button(preload("res://assets/button.png"), _on_end_turn_requested)
	end_turn_button.tooltip_text = "Fim do turno"
	root.add_child(end_turn_button)
	confirm_discard_button = Style.button("Continuar", _confirm_discards)
	confirm_discard_button.hide()
	root.add_child(confirm_discard_button)
	var view_deck := Style.button("Ver baralho", _show_deck)
	view_deck.name = "ViewDeck"
	root.add_child(view_deck)

func _layout() -> void:
	var dimensions := get_viewport().get_visible_rect().size
	player_interface.position = Vector2(roundf((dimensions.x - 600) * 0.5), 8)
	player_interface.size = Vector2(600, 94)
	equation_label.position = Vector2(16, 10)
	equation_label.size = Vector2(300, 78)
	buff_label.position = Vector2(16, 96)
	# Região de soltura ampla; a fileira mantém a carta inteira em tamanho natural.
	drop_zone.position = Vector2(170, 122)
	drop_zone.size = Vector2(dimensions.x - 340, dimensions.y - 348)
	played_container.position = Vector2(roundf((dimensions.x - 672) * 0.5), dimensions.y - 424)
	played_container.size = Vector2(672, 196)
	effect_label.position = Vector2(16, 188)
	effect_label.size = Vector2(280, 90)
	hand_panel.position = Vector2(0, dimensions.y - 216)
	hand_panel.size = Vector2(dimensions.x, 216)
	var hand_width := maxf(dimensions.x - 480, 1.0)
	card_container.position = Vector2(roundf((dimensions.x - hand_width) * 0.5), 10)
	card_container.size = Vector2(hand_width, 196)
	_fit_hand()
	energy_texture.position = Vector2(70, dimensions.y - 216)
	energy_texture.size = Vector2(100, 100)
	deck_label.position = Vector2(100, dimensions.y - 115)
	clear_button.position = Vector2(80, dimensions.y - 52)
	clear_button.size = Vector2(160, 42)
	end_turn_button.position = Vector2(dimensions.x - 210, dimensions.y - 112)
	end_turn_button.size = Vector2(184, 52)
	confirm_discard_button.position = end_turn_button.position
	confirm_discard_button.size = end_turn_button.size
	root.get_node("ViewDeck").position = Vector2(dimensions.x - 190, dimensions.y - 50)
	root.get_node("ViewDeck").size = Vector2(170, 40)

func _draw_hand() -> void:
	var space := HAND_LIMIT - card_container.get_child_count()
	for data in deck.draw(mini(CARDS_PER_TURN, space)):
		create_card(data)

func _fit_hand() -> void:
	var count := card_container.get_child_count()
	var available := get_viewport().get_visible_rect().size.x - 480.0
	var gap := 8
	if count > 1:
		gap = mini(gap, floori((available - count * 128.0) / (count - 1)))
	card_container.add_theme_constant_override("separation", gap)

func create_card(data: Dictionary) -> void:
	var card := CARD_SCENE.instantiate()
	card_container.add_child(card)
	card.setup(data)
	card.drop_zone = drop_zone
	card.card_played.connect(_on_card_played)
	card.card_removed.connect(_on_card_removed)
	card.discard_selected.connect(_toggle_discard)
	card.card_hovered.connect(func(): card_hover_changed.emit(true))
	card.card_exited.connect(func(): card_hover_changed.emit(false))
	card.set_interaction_enabled(selection.enabled)

func set_player_turn(enabled: bool) -> void:
	selection.enabled = enabled
	end_turn_button.disabled = not enabled
	clear_button.disabled = not enabled
	if enabled:
		turn_count += 1
	_refresh_cards()

func _on_end_turn_requested() -> void:
	if not selection.enabled or choosing_discards:
		return
	if card_container.get_child_count() == 0:
		end_turn_requested.emit()
		return
	choosing_discards = true
	end_turn_button.hide()
	clear_button.disabled = true
	confirm_discard_button.show()
	_refresh_cards()

func _toggle_discard(card: Control) -> void:
	if not choosing_discards or card.get_parent() != card_container:
		return
	if selected_discards.has(card):
		selected_discards.erase(card)
	elif selected_discards.size() < DISCARD_LIMIT:
		selected_discards.append(card)
	_refresh_cards()

func _confirm_discards() -> void:
	if choosing_discards:
		end_turn_requested.emit()

func commit_selection() -> Array:
	var cards: Array = selection.cards_data()
	var discarded := cards.duplicate()
	for card in selected_discards:
		discarded.append(card.card_data)
		card_container.remove_child(card)
		card.queue_free()
	for card in played_container.get_children():
		played_container.remove_child(card)
		card.queue_free()
	deck.discard(discarded)
	selected_discards.clear()
	choosing_discards = false
	confirm_discard_button.hide()
	end_turn_button.show()
	_refresh_cards()
	return cards

func start_new_player_round() -> void:
	selection.start_round()
	_draw_hand()
	_refresh_cards()

func _on_card_played(card: Control) -> void:
	if choosing_discards or card.get_parent() != card_container or not selection.try_play(card.get_instance_id(), card.card_data):
		card.return_to_slot()
		return
	card.is_played = true
	card.reparent(played_container, false)
	_refresh_cards()
	selection_changed.emit(selection.cards_data())

func _on_card_removed(card: Control) -> void:
	if choosing_discards or card.get_parent() != played_container or not selection.try_remove(card.get_instance_id()):
		card.return_to_slot()
		return
	card.is_played = false
	card.reparent(card_container, false)
	_refresh_cards()
	selection_changed.emit(selection.cards_data())

func return_all_cards_to_hand() -> void:
	if choosing_discards or not selection.clear():
		return
	for card in played_container.get_children():
		card.is_played = false
		card.reparent(card_container, false)
	_refresh_cards()
	selection_changed.emit(selection.cards_data())

func _refresh_cards() -> void:
	_fit_hand()
	energy_texture.texture = energy_icons[selection.current_energy]
	energy_texture.tooltip_text = "Energia: %d/%d" % [selection.current_energy, selection.max_energy]
	deck_label.text = "Mão: %d/%d\nCompra: %d\nDescarte: %d" % [
		card_container.get_child_count(), HAND_LIMIT, deck.draw_pile.size(), deck.discard_pile.size()
	]
	for container in [card_container, played_container]:
		container.queue_sort()
		for card in container.get_children():
			var affordable: bool = int(card.card_data.energy_cost) <= selection.current_energy
			card.can_select_discard = choosing_discards and selection.enabled and container == card_container
			card.set_interaction_enabled(selection.enabled and not choosing_discards and (affordable or card.is_played))
			card.set_affordable(affordable or card.can_select_discard)
			if selected_discards.has(card):
				card.modulate = Color(1.0, 0.60, 0.60)
	if choosing_discards:
		effect_label.text = "Clique em até %d cartas da mão para descartar.\nSelecionadas: %d/%d" % [
			DISCARD_LIMIT, selected_discards.size(), DISCARD_LIMIT
		]
		effect_label.show()
		return
	var effects: Dictionary = Effects.aggregate(selection.cards_data())
	var parts: Array[String] = []
	for key in ["heal", "shield", "poison", "damage"]:
		if int(effects[key]) > 0:
			parts.append({"heal":"Cura", "shield":"Escudo", "poison":"Veneno nos alvos", "damage":"Dano extra"}[key] + " +%d" % effects[key])
	effect_label.text = " • ".join(parts)
	effect_label.visible = not parts.is_empty()

func update_equation(text: String) -> void:
	equation_label.text = text
	equation_label.tooltip_text = text

func update_player_status(status: Dictionary) -> void:
	player_interface.update_player_info(status.health, status.max_health, status.poison_amount, status.shield, status.thorns)
	var active: Array[String] = []
	if int(status.strength) > 0:
		active.append("Força: %d" % status.strength)
	if int(status.weak) > 0:
		active.append("Fraqueza: %d" % status.weak)
	buff_label.text = " • ".join(active)
	buff_label.visible = not active.is_empty()

func _show_deck() -> void:
	add_child(load("res://interface/deck_viewer.gd").new())
