extends Node

const CARDS = [

	# ========================================================
	# POSIÇÕES 0 A 5: DESLOCAMENTO NOS EIXOS X E Y
	# ========================================================
	{
		"id": 1,
		"type": "quadratic",
		"coefficient": "c",
		"value": 1.0, # [Posição 0] Soma +1 no Eixo Y
	},
	{
		"id": 2,
		"type": "quadratic",
		"coefficient": "c",
		"value": 2.0, # [Posição 1] Soma +2 no Eixo Y
	},
	{
		"id": 3,
		"type": "quadratic",
		"coefficient": "b",
		"value": -2.0, # [Posição 2] Move +1 no Eixo X (Forma canônica)
	},
	{
		"id": 4,
		"type": "quadratic",
		"coefficient": "b",
		"value": -4.0, # [Posição 3] Move +2 no Eixo X (Forma canônica)
	},
	{
		"id": 5,
		"type": "quadratic",
		"coefficient": "b",
		"value": 1.0, # [Posição 4] Mantida da lista anterior
	},
	{
		"id": 6,
		"type": "quadratic",
		"coefficient": "b",
		"value": -1.0, # [Posição 5] Mantida da lista anterior
	},

	# ========================================================
	# RESTANTE DO ARRAY (Mantendo os combos anteriores)
	# ========================================================
	{
		"id": 7,
		"type": "quadratic",
		"coefficient": "b",
		"value": 2.0,
	},
	{
		"id": 8,
		"type": "quadratic",
		"coefficient": "b",
		"value": 2.0,
	},
	{
		"id": 9,
		"type": "quadratic",
		"coefficient": "b",
		"value": -2.0,
	},
	{
		"id": 10,
		"type": "quadratic",
		"coefficient": "c",
		"value": 2.0,
	},
	{
		"id": 11,
		"type": "quadratic",
		"coefficient": "c",
		"value": -2.0,
	},
	{
		"id": 12,
		"type": "quadratic",
		"coefficient": "c",
		"value": 2.0,
	},
	{
		"id": 13,
		"type": "quadratic",
		"coefficient": "c",
		"value": -2.0,
	},
	{
		"id": 14,
		"type": "quadratic",
		"coefficient": "a",
		"value": 3.0,
	},
	{
		"id": 15,
		"type": "quadratic",
		"coefficient": "a",
		"value": -3.0,
	},
]
