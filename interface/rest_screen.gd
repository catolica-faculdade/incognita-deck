extends Control

const Style = preload("res://interface/ui_style.gd")
const Catalog = preload("res://card/card_database.gd")

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
	removal.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	removal.size_flags_vertical = Control.SIZE_EXPAND_FILL
	removal.custom_minimum_size.x = 460
	removal.add_theme_constant_override("separation", 8)
	content.add_child(removal)
	removal.add_child(Style.readable_label("Escolha uma carta para remover do baralho.", 17))
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	removal.add_child(scroll)
	var cards := VBoxContainer.new()
	cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cards.add_theme_constant_override("separation", 6)
	scroll.add_child(cards)
	var counts := {}
	for id in GameManager.run_deck:
		counts[id] = int(counts.get(id, 0)) + 1
	for id in counts:
		var data := Catalog.get_card(int(id))
		var button := Style.button("%s  ×%d" % [data.name, counts[id]], _remove.bind(int(id)))
		var description := Catalog.description(data)
		button.tooltip_text = description if data.type == "effect" else Catalog.math_text(data) + "\n" + description
		cards.add_child(button)
	removal.add_child(Style.button("Voltar", _show_removal.bind(false)))
	_show_removal(false)

func _show_removal(show_cards: bool) -> void:
	actions.visible = not show_cards
	removal.visible = show_cards

func _heal() -> void:
	GameManager.complete_rest()

func _remove(id: int) -> void:
	GameManager.complete_rest(id)
