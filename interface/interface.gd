extends CanvasLayer

@onready var card_container = $MarginContainer/Control/HBoxContainer

const CARDS = preload("res://card/card_database.gd").CARDS
const card_scene = preload("res://card/card.tscn")
var world

func _ready() -> void:
	create_card(CARDS[0])
	create_card(CARDS[1])
	create_card(CARDS[2])

# func _process(delta: float) -> void:
#	pass

func create_card(data):
	var card = card_scene.instantiate()
	card_container.add_child(card)
	card.pressed.connect(_on_card_pressed)
	card.setup(data)

func set_world(w):
	world = w
	
func _on_card_pressed(value, axis):
	world.apply_card(value, axis)
