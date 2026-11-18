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
const CARDS_PER_TURN := 5
const RETENTION_LIMIT := 2
const CARD_KEYS := [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_0]
const KEYPAD_CARD_KEYS := [KEY_KP_1, KEY_KP_2, KEY_KP_3, KEY_KP_4, KEY_KP_5, KEY_KP_6, KEY_KP_7, KEY_KP_8, KEY_KP_9, KEY_KP_0]
const MESSAGE_PANEL_WIDTH := 296.0
const ENERGY_IMAGES = [
	preload("res://energy/energy_0.png"), preload("res://energy/energy_1.png"),
	preload("res://energy/energy_2.png"), preload("res://energy/energy_3.png"),
	preload("res://energy/energy_4.png"), preload("res://energy/energy_5.png")
]
var selection = Selection.new(5)
var deck = Deck.new()
var turn_count := 0
var choosing_retention := false
var reviewing_cards := false
var retained_cards: Array[Control] = []
var card_container: HBoxContainer
var played_container: HBoxContainer
var equation_label: Label
var arena_rule_label: Label
var energy_texture: TextureRect
var energy_icons: Array[AtlasTexture] = []
var player_interface: Control
var buff_label: Label
var deck_label: Label
var message_panel: PanelContainer
var message_title: Label
var effect_label: Label
var shortcut_help: Label
var retention_row: HBoxContainer
var retention_slots: Array[Label] = []
var empty_slot_style: StyleBoxFlat
var filled_slot_style: StyleBoxFlat
var end_turn_button: Button
var turn_keys_label: Label
var confirm_keep_button: Button
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
	arena_rule_label = Style.readable_label("", 15)
	arena_rule_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(arena_rule_label)
	arena_rule_label.hide()
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
	_build_message_panel()
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
	end_turn_button.tooltip_text = "Fim do turno (E ou Espaço)"
	root.add_child(end_turn_button)
	turn_keys_label = _key_hint("E  /  Espaço")
	root.add_child(turn_keys_label)
	confirm_keep_button = Style.button("Continuar", _confirm_retention)
	confirm_keep_button.hide()
	root.add_child(confirm_keep_button)
	var view_deck := Style.button("Ver baralho  [Tab]", _show_deck)
	view_deck.name = "ViewDeck"
	root.add_child(view_deck)

func _key_hint(text: String) -> Label:
	var hint := Style.readable_label(text, 14)
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var paper := StyleBoxFlat.new()
	paper.bg_color = Color("fff8e6")
	paper.border_color = Color("7d6b50")
	paper.set_border_width_all(1)
	paper.set_corner_radius_all(4)
	hint.add_theme_stylebox_override("normal", paper)
	return hint

func _build_message_panel() -> void:
	var corner := VBoxContainer.new()
	corner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(corner)
	corner.anchor_left = 1.0
	corner.anchor_right = 1.0
	corner.offset_left = -MESSAGE_PANEL_WIDTH - 16.0
	corner.offset_right = -16.0
	corner.offset_top = 10.0

	message_panel = PanelContainer.new()
	message_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var paper := StyleBoxFlat.new()
	paper.bg_color = Color("fffcf3")
	paper.border_color = Color("b7ab91")
	paper.set_border_width_all(1)
	paper.set_corner_radius_all(10)
	paper.shadow_color = Color(0.20, 0.16, 0.10, 0.16)
	paper.shadow_size = 4
	paper.shadow_offset = Vector2(0, 2)
	paper.set_content_margin(SIDE_LEFT, 14)
	paper.set_content_margin(SIDE_RIGHT, 14)
	paper.set_content_margin(SIDE_TOP, 10)
	paper.set_content_margin(SIDE_BOTTOM, 12)
	message_panel.add_theme_stylebox_override("panel", paper)
	corner.add_child(message_panel)

	var content := VBoxContainer.new()
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_theme_constant_override("separation", 6)
	message_panel.add_child(content)
	message_title = Style.readable_label("", 19)
	content.add_child(message_title)
	effect_label = Style.readable_label("", 15)
	effect_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(effect_label)

	retention_row = HBoxContainer.new()
	retention_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	retention_row.add_theme_constant_override("separation", 8)
	content.add_child(retention_row)
	empty_slot_style = StyleBoxFlat.new()
	empty_slot_style.bg_color = Color("f4eddb")
	empty_slot_style.border_color = Color("a79a7d")
	empty_slot_style.set_border_width_all(1)
	empty_slot_style.set_corner_radius_all(5)
	filled_slot_style = empty_slot_style.duplicate() as StyleBoxFlat
	filled_slot_style.bg_color = Color("d6ebd2")
	filled_slot_style.border_color = Color("47724a")
	for i in range(RETENTION_LIMIT):
		var slot := Style.readable_label("+", 19)
		slot.custom_minimum_size = Vector2(34, 44)
		slot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		retention_row.add_child(slot)
		retention_slots.append(slot)
	shortcut_help = Style.readable_label("", 13)
	content.add_child(shortcut_help)

func _layout() -> void:
	var dimensions := get_viewport().get_visible_rect().size
	player_interface.position = Vector2(roundf((dimensions.x - 600) * 0.5), 8)
	player_interface.size = Vector2(600, 94)
	equation_label.position = Vector2(16, 10)
	equation_label.size = Vector2(300, 78)
	arena_rule_label.position = Vector2(dimensions.x * 0.5 - 180, 108)
	arena_rule_label.size = Vector2(360, 24)
	buff_label.position = Vector2(16, 96)
	# Região de soltura ampla; a fileira mantém a carta inteira em tamanho natural.
	drop_zone.position = Vector2(170, 122)
	drop_zone.size = Vector2(dimensions.x - 340, dimensions.y - 348)
	played_container.position = Vector2(roundf((dimensions.x - 672) * 0.5), dimensions.y - 424)
	played_container.size = Vector2(672, 196)
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
	turn_keys_label.position = end_turn_button.position + Vector2(43, -25)
	turn_keys_label.size = Vector2(98, 22)
	confirm_keep_button.position = end_turn_button.position
	confirm_keep_button.size = end_turn_button.size
	root.get_node("ViewDeck").position = Vector2(dimensions.x - 190, dimensions.y - 50)
	root.get_node("ViewDeck").size = Vector2(170, 40)

func _draw_hand() -> void:
	for data in deck.draw(CARDS_PER_TURN):
		create_card(data)
	var hand := card_container.get_children()
	for i in range(hand.size()):
		var card := hand[i]
		var hint := card.get_node_or_null("ShortcutKey") as Label
		if i >= CARD_KEYS.size():
			if hint != null:
				card.remove_child(hint)
				hint.queue_free()
			continue
		if hint == null:
			hint = _key_hint("")
			hint.name = "ShortcutKey"
			hint.position = Vector2(7, -12)
			hint.size = Vector2(23, 23)
			hint.z_index = 3
			card.add_child(hint)
		hint.text = str((i + 1) % 10)
		hint.set_meta("slot", i)

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
	card.retention_selected.connect(_toggle_retention)
	card.card_hovered.connect(func(): card_hover_changed.emit(true))
	card.card_exited.connect(func(): card_hover_changed.emit(false))
	card.set_interaction_enabled(selection.enabled)

func set_player_turn(enabled: bool) -> void:
	selection.enabled = enabled
	if not enabled:
		reviewing_cards = false
	end_turn_button.disabled = not enabled
	clear_button.disabled = not enabled
	if enabled:
		turn_count += 1
	_refresh_cards()

func _on_end_turn_requested() -> void:
	if not selection.enabled or choosing_retention:
		return
	if card_container.get_child_count() == 0:
		end_turn_requested.emit()
		return
	choosing_retention = true
	end_turn_button.hide()
	clear_button.disabled = true
	confirm_keep_button.show()
	_refresh_cards()

func _toggle_retention(card: Control) -> void:
	if not choosing_retention or card.get_parent() != card_container:
		return
	if retained_cards.has(card):
		retained_cards.erase(card)
	elif retained_cards.size() < RETENTION_LIMIT:
		retained_cards.append(card)
	_refresh_cards()

func _confirm_retention() -> void:
	if choosing_retention:
		end_turn_requested.emit()

func commit_selection() -> Array:
	var cards: Array = selection.cards_data()
	var discarded := cards.duplicate()
	for card in card_container.get_children():
		if retained_cards.has(card):
			continue
		discarded.append(card.card_data)
		card_container.remove_child(card)
		card.queue_free()
	for card in played_container.get_children():
		played_container.remove_child(card)
		card.queue_free()
	deck.discard(discarded)
	retained_cards.clear()
	choosing_retention = false
	confirm_keep_button.hide()
	end_turn_button.show()
	_refresh_cards()
	return cards

func start_new_player_round() -> void:
	selection.start_round()
	_draw_hand()
	_refresh_cards()

func _on_card_played(card: Control) -> void:
	if choosing_retention or card.get_parent() != card_container or not selection.try_play(card.get_instance_id(), card.card_data):
		card.return_to_slot()
		return
	card.is_played = true
	card.reparent(played_container, false)
	_refresh_cards()
	selection_changed.emit(selection.cards_data())

func _on_card_removed(card: Control) -> void:
	if choosing_retention or card.get_parent() != played_container or not selection.try_remove(card.get_instance_id()):
		card.return_to_slot()
		return
	card.is_played = false
	_restore_hand_position(card)
	_refresh_cards()
	selection_changed.emit(selection.cards_data())

func return_all_cards_to_hand() -> void:
	if choosing_retention or not selection.clear():
		return
	for card in played_container.get_children():
		card.is_played = false
		_restore_hand_position(card)
	_refresh_cards()
	selection_changed.emit(selection.cards_data())

func _restore_hand_position(card: Control) -> void:
	card.reparent(card_container, false)
	var hint := card.get_node_or_null("ShortcutKey")
	if hint == null:
		return
	for other in card_container.get_children():
		var other_hint := other.get_node_or_null("ShortcutKey")
		if other_hint == null or int(other_hint.get_meta("slot")) > int(hint.get_meta("slot")):
			card_container.move_child(card, other.get_index())
			break

func _refresh_cards() -> void:
	_fit_hand()
	turn_keys_label.visible = selection.enabled
	energy_texture.texture = energy_icons[selection.current_energy]
	energy_texture.tooltip_text = "Energia: %d/%d" % [selection.current_energy, selection.max_energy]
	deck_label.text = "Mão: %d\nCompra: %d\nDescarte: %d" % [
		card_container.get_child_count(), deck.draw_pile.size(), deck.discard_pile.size()
	]
	for container in [card_container, played_container]:
		container.queue_sort()
		for card in container.get_children():
			var affordable: bool = int(card.card_data.energy_cost) <= selection.current_energy
			card.can_select_retention = choosing_retention and selection.enabled and container == card_container
			card.set_interaction_enabled(selection.enabled and not choosing_retention and (affordable or card.is_played))
			card.set_affordable(affordable or card.can_select_retention)
			var hint := card.get_node_or_null("ShortcutKey") as Label
			if hint != null:
				hint.visible = selection.enabled and (not choosing_retention or card.can_select_retention)
				var can_keep: bool = card.can_select_retention and (retained_cards.has(card) or retained_cards.size() < RETENTION_LIMIT)
				hint.modulate.a = 1.0 if card.interaction_enabled or can_keep else 0.55
			if retained_cards.has(card):
				card.modulate = Color(0.70, 1.0, 0.72)
	_refresh_message_panel()

func _refresh_message_panel() -> void:
	message_panel.visible = selection.enabled
	retention_row.visible = choosing_retention
	shortcut_help.text = "Esc  Pausar" if choosing_retention else "Ctrl  Revisar cartas    •    Esc  Pausar"
	if choosing_retention:
		message_title.text = "Manter cartas"
		effect_label.text = "Clique ou use a tecla da carta para manter até %d. As demais vão para o descarte." % RETENTION_LIMIT
		for i in range(retention_slots.size()):
			var slot := retention_slots[i]
			var filled := i < retained_cards.size()
			slot.text = "✓" if filled else "+"
			slot.add_theme_stylebox_override("normal", filled_slot_style if filled else empty_slot_style)
		return
	if reviewing_cards:
		message_title.text = "Cartas preparadas"
		var names: Array[String] = []
		for card in selection.cards_data():
			names.append(card.name)
		effect_label.text = "Nenhuma carta preparada." if names.is_empty() else "\n".join(names)
		return
	var effects: Dictionary = Effects.aggregate(selection.cards_data())
	var parts: Array[String] = []
	for key in ["heal", "shield", "poison", "damage"]:
		if int(effects[key]) > 0:
			parts.append({"heal":"Cura", "shield":"Escudo", "poison":"Veneno nos alvos", "damage":"Dano extra"}[key] + " +%d" % effects[key])
	message_title.text = "Preparar jogada" if parts.is_empty() else "Efeitos da jogada"
	effect_label.text = "Arraste uma carta ou pressione a tecla indicada nela." if parts.is_empty() else "\n".join(parts)

func update_equation(text: String) -> void:
	equation_label.text = text
	equation_label.tooltip_text = text

func show_arena_rule(rule: String) -> void:
	arena_rule_label.visible = not rule.is_empty()
	arena_rule_label.text = "Arena: " + rule

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

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_TAB:
		get_viewport().set_input_as_handled()
		_show_deck()
	elif selection.enabled:
		var slot := CARD_KEYS.find(event.keycode)
		if slot == -1:
			slot = KEYPAD_CARD_KEYS.find(event.keycode)
		if slot >= 0:
			get_viewport().set_input_as_handled()
			_use_card_key(slot)
			return
		match event.keycode:
			KEY_E, KEY_SPACE:
				get_viewport().set_input_as_handled()
				if choosing_retention:
					_confirm_retention()
				else:
					_on_end_turn_requested()
			KEY_CTRL:
				if choosing_retention:
					return
				get_viewport().set_input_as_handled()
				reviewing_cards = not reviewing_cards
				_refresh_message_panel()

func _use_card_key(slot: int) -> void:
	var cards := card_container.get_children() + played_container.get_children()
	if cards.any(func(card): return card.dragging):
		return
	for card in cards:
		var hint := card.get_node_or_null("ShortcutKey") as Label
		if hint == null or hint.get_meta("slot") != slot:
			continue
		if choosing_retention:
			_toggle_retention(card)
		elif card.is_played and card.interaction_enabled:
			_on_card_removed(card)
		elif card.interaction_enabled:
			_on_card_played(card)
		return
