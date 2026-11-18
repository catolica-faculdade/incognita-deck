extends Control

const Style = preload("res://interface/ui_style.gd")
const Catalog = preload("res://card/card_database.gd")
const CARD_SCENE = preload("res://card/card.tscn")

var actions: VBoxContainer
var removal: VBoxContainer

func _ready() -> void:
	var status := "HP %d/%d • Escolha um benefício" % [GameManager.player_health, GameManager.max_player_health]
	var content := Style.screen(self, "Descanso", status)
	actions = VBoxContainer.new()
	actions.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	actions.custom_minimum_size.x = 440
	actions.add_theme_constant_override("separation", 12)
	content.add_child(actions)
	actions.add_child(Style.button("Curar %d HP (40%% da vida máxima)" % GameManager.rest_heal_amount(), _heal))
	var remove_button := Style.button("Remover uma carta", _show_removal.bind(true))
	remove_button.disabled = GameManager.run_deck.size() <= 1
	actions.add_child(remove_button)

	removal = VBoxContainer.new()
	removal.size_flags_vertical = Control.SIZE_EXPAND_FILL
	removal.add_theme_constant_override("separation", 8)
	content.add_child(removal)
	var instructions := Style.readable_label("Escolha uma carta para remover do baralho.", 17)
	instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	removal.add_child(instructions)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.follow_focus = true
	removal.add_child(scroll)
	var cards := HFlowContainer.new()
	cards.name = "RemovalCards"
	cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cards.alignment = FlowContainer.ALIGNMENT_CENTER
	cards.add_theme_constant_override("h_separation", 16)
	cards.add_theme_constant_override("v_separation", 12)
	scroll.add_child(cards)
	var counts := {}
	for id in GameManager.run_deck:
		counts[id] = int(counts.get(id, 0)) + 1
	for id in counts:
		_add_removal_card(cards, int(id), int(counts[id]))
	removal.add_child(Style.button("Voltar", _show_removal.bind(false)))
	_show_removal(false)

func _add_removal_card(grid: HFlowContainer, id: int, copies: int) -> void:
	var column := VBoxContainer.new()
	column.custom_minimum_size.x = 152
	column.add_theme_constant_override("separation", 6)
	grid.add_child(column)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_top", 16)
	column.add_child(margin)
	var card_center := CenterContainer.new()
	margin.add_child(card_center)
	var card := CARD_SCENE.instantiate()
	card.name = "CardPreview"
	card_center.add_child(card)
	card.setup(Catalog.get_card(id))
	var count := Style.readable_label("1 cópia" if copies == 1 else "%d cópias" % copies, 14)
	count.name = "Copies"
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(count)
	var button := Style.button("Remover 1", _remove.bind(id))
	button.name = "RemoveCopy"
	column.add_child(button)

func _show_removal(show_cards: bool) -> void:
	actions.visible = not show_cards
	removal.visible = show_cards

func _heal() -> void:
	GameManager.complete_rest()

func _remove(id: int) -> void:
	GameManager.complete_rest(id)
