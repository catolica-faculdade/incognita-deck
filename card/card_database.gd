extends Node

const CARDS = [

	# =========================
	# A COEFFICIENT (abertura)
	# =========================

	{
		"id": 1,
		"type": "quadratic",
		"coefficient": "a",
		"value": 1.0,
		#"texture": preload("res://assets/cards/a_plus_1.png")
	},

	{
		"id": 2,
		"type": "quadratic",
		"coefficient": "a",
		"value": -1.0,
		#"texture": preload("res://assets/cards/a_minus_1.png")
	},

	{
		"id": 3,
		"type": "quadratic",
		"coefficient": "a",
		"value": 0.5,
		#"texture": preload("res://assets/cards/a_plus_half.png")
	},

	{
		"id": 4,
		"type": "quadratic",
		"coefficient": "a",
		"value": -0.5,
		#"texture": preload("res://assets/cards/a_minus_half.png")
	},

	# =========================
	# B COEFFICIENT (inclinação)
	# =========================

	{
		"id": 5,
		"type": "quadratic",
		"coefficient": "b",
		"value": 1.0,
		#"texture": preload("res://assets/cards/b_plus_1.png")
	},

	{
		"id": 6,
		"type": "quadratic",
		"coefficient": "b",
		"value": -1.0,
		#"texture": preload("res://assets/cards/b_minus_1.png")
	},

	{
		"id": 7,
		"type": "quadratic",
		"coefficient": "b",
		"value": 2.0,
		#"texture": preload("res://assets/cards/b_plus_2.png")
	},

	{
		"id": 8,
		"type": "quadratic",
		"coefficient": "b",
		"value": -2.0,
		#"texture": preload("res://assets/cards/b_minus_2.png")
	},

	# =========================
	# C COEFFICIENT (altura)
	# =========================

	{
		"id": 9,
		"type": "quadratic",
		"coefficient": "c",
		"value": 1.0,
		#"texture": preload("res://assets/cards/c_plus_1.png")
	},

	{
		"id": 10,
		"type": "quadratic",
		"coefficient": "c",
		"value": -1.0,
		#"texture": preload("res://assets/cards/c_minus_1.png")
	},

	{
		"id": 11,
		"type": "quadratic",
		"coefficient": "c",
		"value": 2.0,
		#"texture": preload("res://assets/cards/c_plus_2.png")
	},

	{
		"id": 12,
		"type": "quadratic",
		"coefficient": "c",
		"value": -2.0,
		#"texture": preload("res://assets/cards/c_minus_2.png")
	},

	# =========================
	# TESTE EXTREMO 🔥
	# =========================

	{
		"id": 13,
		"type": "quadratic",
		"coefficient": "a",
		"value": 3.0,
		#"texture": preload("res://assets/cards/a_plus_3.png")
	},

	{
		"id": 14,
		"type": "quadratic",
		"coefficient": "a",
		"value": -3.0,
		#"texture": preload("res://assets/cards/a_minus_3.png")
	},
]
