extends CanvasLayer

@onready var card_container = $MarginContainer/Control/HBoxContainer
@onready var equation_label = $MarginContainer/Buttons/EquationLabel
@onready var played_container = $MarginContainer/Control/PlayedCards

const CARDS = preload("res://card/card_database.gd").CARDS
const card_scene = preload("res://card/card.tscn")

var battle_system

var played_cards: Array = []


func _ready() -> void:
	create_card(CARDS[0])
	create_card(CARDS[1])
	create_card(CARDS[2])
	create_card(CARDS[3])
	create_card(CARDS[4])


func create_card(data):

	var card = card_scene.instantiate()

	card_container.add_child(card)

	card.setup(data)

	card.card_played.connect(_on_card_played)
	card.card_removed.connect(_on_card_removed)


func _on_card_played(card):

	if played_cards.has(card):
		return

	if card.get_parent():
		card.get_parent().remove_child(card)

	played_container.add_child(card)

	played_container.move_child(
		card,
		played_container.get_child_count() - 1
	)

	played_cards.append(card)

	recalculate_cards()


func _on_card_removed(card):

	if played_cards.has(card):
		played_cards.erase(card)

	if card.get_parent():
		card.get_parent().remove_child(card)

	card_container.add_child(card)

	recalculate_cards()


func recalculate_cards():

	if not battle_system:
		return

	battle_system.clear_trajectory()

	for card in played_cards:
		battle_system.apply_card(card.card_data)


func set_battle_system(bs):
	battle_system = bs


func _on_clear_trajectory_pressed():
	if battle_system:
		battle_system.clear_trajectory()


func update_equation(text: String):
	equation_label.text = text
