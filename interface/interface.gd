extends CanvasLayer

@onready var card_container = $MarginContainer/Control/HBoxContainer
@onready var equation_label = $MarginContainer/Buttons/EquationLabel
@onready var turn_label: Label = $MarginContainer/Buttons/TurnLabel
@onready var turn_counter_label: Label = $MarginContainer/Buttons/TurnCounterLabel

const CARDS = preload("res://card/card_database.gd").CARDS
const card_scene = preload("res://card/card.tscn")

var battle_system

var turn_count := 1

func _ready() -> void:
	create_card(CARDS[0])
	create_card(CARDS[1])
	create_card(CARDS[2])
	create_card(CARDS[3])
	create_card(CARDS[4])
	set_turn_indicator(true)

func create_card(data):
	var card = card_scene.instantiate()
	card_container.add_child(card)
	card.setup(data)
	card.card_pressed.connect(_on_card_pressed)
	card.card_hovered.connect(_on_card_hovered)
	card.card_exited.connect(_on_card_exited)

func set_turn_indicator(is_player_turn: bool) -> void:
	if is_player_turn:
		turn_label.text = "✦ SEU TURNO"
		turn_label.modulate = Color(0.2, 0.8, 0.2)
		turn_counter_label.text = "Turno %d" % turn_count
		turn_count += 1
	else:
		turn_label.text = "⚔ TURNO INIMIGO"
		turn_label.modulate = Color(0.9, 0.2, 0.2)

func _on_card_hovered():
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("on_card_hovered"):
		player.on_card_hovered()

func _on_card_exited():
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("on_card_exited"):
		player.on_card_exited()

func _on_card_pressed(card_data: Dictionary):
	battle_system.apply_card(card_data)

func set_battle_system(bs):
	battle_system = bs

func _on_clear_trajectory_pressed():
	if battle_system:
		battle_system.clear_trajectory()

func update_equation(text: String):
	equation_label.text = text
