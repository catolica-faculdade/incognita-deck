extends Node

const CARDS = [
	{
		"id": 1,
		"name": "Avanço",
		"type": "linear",
		"x": 4.0,
		"y": 0.0,
		"energy_cost": 1,
		"draw_chance": 70,
		"texture": preload("res://assets/cards/card_avanco.jpg")
	},
	{
		"id": 2,
		"name": "Elevar",
		"type": "linear",
		"x": 3.0,
		"y": 2.0,
		"energy_cost": 1,
		"draw_chance": 15,
		"texture": preload("res://assets/cards/card_eleva.jpg")
	},
	{
		"id": 3,
		"name": "Arco",
		"type": "quadratic",
		"coefficient": "a",
		"value": 0.35,
		"energy_cost": 1,
		"draw_chance": 5,
		"texture": preload("res://assets/cards/card_arc.jpg")
	},
	{
		"id": 4,
		"name": "Queda",
		"type": "quadratic",
		"coefficient": "a",
		"value": -0.35,
		"energy_cost": 1,
		"draw_chance": 5,
		"texture": preload("res://assets/cards/card_queda.jpg")
	},
	{
		"id": 5,
		"name": "Onda",
		"type": "special",
		"special_type": "wave",
		"amplitude": 1.5,
		"frequency": 2.0,
		"length": 8.0,
		"energy_cost": 1,
		"draw_chance": 10,
		"texture": preload("res://assets/cards/card_onda.jpg")
	}
]
