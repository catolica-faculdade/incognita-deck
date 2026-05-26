extends CanvasLayer

@onready var card_container = $MarginContainer/Control/HBoxContainer
@onready var equation_label = $MarginContainer/Buttons/EquationLabel

const CARDS = preload("res://card/card_database.gd").CARDS
const card_scene = preload("res://card/card.tscn")

var battle_system

func _ready() -> void:
	create_card(CARDS[0])
	create_card(CARDS[1])
	create_card(CARDS[2])
	create_card(CARDS[3])
	create_card(CARDS[9])

func create_card(data):
	var card = card_scene.instantiate()
	card_container.add_child(card)
	card.setup(data)
	card.card_pressed.connect(_on_card_pressed)
	
func _on_card_pressed(card_data: Dictionary):
	battle_system.apply_card(card_data)
	
func set_battle_system(bs):
	battle_system = bs

func _on_clear_trajectory_pressed():
	if battle_system:
		battle_system.clear_trajectory()

func update_equation(text: String):
	equation_label.text = text
