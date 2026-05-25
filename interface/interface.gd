extends CanvasLayer

@onready var card_container = $MarginContainer/Control/HBoxContainer

const CARDS = preload("res://card/card_database.gd").CARDS
const card_scene = preload("res://card/card.tscn")

var battle_system

func _ready() -> void:
	create_card(CARDS[0])
	#create_card(CARDS[1])
	create_card(CARDS[2])
	#create_card(CARDS[3])
	create_card(CARDS[4])
	#create_card(CARDS[5])
	create_card(CARDS[6])
	#create_card(CARDS[7])

func create_card(data):
	var card = card_scene.instantiate()
	card_container.add_child(card)
	card.setup(data)
	card.card_pressed.connect(_on_card_pressed)
	
func _on_card_pressed(value, axis):
	battle_system.apply_card(value, axis)
	
func set_battle_system(bs):
	battle_system = bs
