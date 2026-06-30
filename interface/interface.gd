extends CanvasLayer

@onready var card_container = $MarginContainer/Control/HBoxContainer
@onready var equation_label = $MarginContainer/Buttons/EquationLabel
@onready var played_container = $MarginContainer/Control/PlayedCards
@onready var energy_texture = $energyTexture
@onready var turn_label: Label = $MarginContainer/Buttons/TurnLabel
@onready var turn_counter_label: Label = $MarginContainer/Buttons/TurnCounterLabel

const CARDS = preload("res://card/card_database.gd").CARDS
const card_scene = preload("res://card/card.tscn")

var battle_system

var turn_count := 1

var played_cards: Array = []

var max_energy := 5
var current_energy := 5
var energy_recovery_per_round := 2

var max_hand_size := 5

var energy_images := {
	0: preload("res://energy/energy_0.png"),
	1: preload("res://energy/energy_1.png"),
	2: preload("res://energy/energy_2.png"),
	3: preload("res://energy/energy_3.png"),
	4: preload("res://energy/energy_4.png"),
	5: preload("res://energy/energy_5.png")
}


func _ready() -> void:
	randomize()

	update_energy_ui()

	print("Energia inicial: ", current_energy)

	create_card(CARDS[0])
	create_card(CARDS[1])
	create_card(CARDS[2])
	create_card(CARDS[3])
	create_card(CARDS[4])
	set_turn_indicator(true)

func set_turn_indicator(is_player_turn: bool) -> void:
	if is_player_turn:
		turn_label.text = "✦ SEU TURNO"
		turn_label.modulate = Color(0.2, 0.8, 0.2)
		turn_counter_label.text = "Turno %d" % turn_count
		turn_count += 1
	else:
		turn_label.text = "⚔ TURNO INIMIGO"
		turn_label.modulate = Color(0.9, 0.2, 0.2)

func create_card(data: Dictionary):

	var card = card_scene.instantiate()

	card_container.add_child(card)

	card.setup(data)

	card.card_played.connect(_on_card_played)
	card.card_removed.connect(_on_card_removed)
	card.card_hovered.connect(_on_card_hovered)
	card.card_exited.connect(_on_card_exited)

func draw_random_card():

	var random_index = randi_range(0, CARDS.size() - 1)

	create_card(CARDS[random_index])


func refill_hand():

	while card_container.get_child_count() < max_hand_size:
		draw_random_card()


func discard_played_cards():

	for card in played_cards:
		if is_instance_valid(card):
			card.queue_free()

	played_cards.clear()


func recover_energy():

	current_energy = max_energy

	update_energy_ui()

	print("Energia resetada. Energia atual: ", current_energy)


func start_new_player_round():

	print("Iniciando novo round do jogador")

	discard_played_cards()

	recover_energy()

	refill_hand()

	recalculate_cards()


func _on_card_played(card):

	if played_cards.has(card):
		return

	var energy_cost: int = int(card.card_data.get("energy_cost", 1))

	if current_energy < energy_cost:
		print("Sem energia suficiente para jogar a carta: ", card.card_data.get("name", "Carta"))

		card.is_played = false
		card.return_to_hand()

		return

	if card.get_parent():
		card.get_parent().remove_child(card)

	played_container.add_child(card)

	played_container.move_child(
		card,
		played_container.get_child_count() - 1
	)

	played_cards.append(card)

	current_energy -= energy_cost
	current_energy = max(current_energy, 0)

	update_energy_ui()

	print("Carta jogada: ", card.card_data.get("name", "Carta"))
	print("Energia atual: ", current_energy)

	recalculate_cards()


func _on_card_removed(card):

	var energy_cost: int = int(card.card_data.get("energy_cost", 1))

	if played_cards.has(card):
		played_cards.erase(card)

	if card.get_parent():
		card.get_parent().remove_child(card)

	card_container.add_child(card)

	current_energy += energy_cost
	current_energy = min(current_energy, max_energy)

	update_energy_ui()

	print("Carta removida: ", card.card_data.get("name", "Carta"))
	print("Energia atual: ", current_energy)

	recalculate_cards()


func _on_card_hovered():
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("on_card_hovered"):
		player.on_card_hovered()

func _on_card_exited():
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("on_card_exited"):
		player.on_card_exited()


func update_energy_ui():

	if not energy_texture:
		print("energyTexture não encontrado!")
		return

	if energy_images.has(current_energy):
		energy_texture.texture = energy_images[current_energy]
	else:
		print("Imagem de energia não encontrada para: ", current_energy)


func recalculate_cards():

	if not battle_system:
		return

	var cards_data := []

	for card in played_cards:
		cards_data.append(card.card_data)

	if battle_system.has_method("rebuild_cards_formula"):
		battle_system.rebuild_cards_formula(cards_data)
	else:
		battle_system.clear_trajectory()

		for card in played_cards:
			battle_system.apply_card(card.card_data)


func set_battle_system(bs):
	battle_system = bs


func _on_clear_trajectory_pressed():
	return_all_cards_to_hand()

	if battle_system:
		battle_system.clear_trajectory()


func update_equation(text: String):
	equation_label.text = text

func return_all_cards_to_hand():

	for card in played_cards.duplicate():
		card.is_played = false
		
		if card.get_parent():
			card.get_parent().remove_child(card)
			
		card_container.add_child(card)
		var energy_cost := int(card.card_data.get("energy_cost", 1))
		current_energy += energy_cost
		
	current_energy = min(current_energy, max_energy)
	played_cards.clear()
	update_energy_ui()
	recalculate_cards()
