extends RefCounted
## Pilhas pertencem ao combate; o catálogo e o baralho da run não são modificados.

const Catalog = preload("res://card/card_database.gd")
var draw_pile: Array = []
var discard_pile: Array = []
var rng := RandomNumberGenerator.new()

func setup(card_ids: Array, deck_seed: int) -> void:
	rng.seed = deck_seed
	draw_pile = card_ids.duplicate()
	discard_pile.clear()
	_shuffle(draw_pile)

func draw(amount: int) -> Array:
	var cards: Array = []
	for i in range(amount):
		if draw_pile.is_empty():
			draw_pile = discard_pile.duplicate()
			discard_pile.clear()
			_shuffle(draw_pile)
		if draw_pile.is_empty():
			break
		cards.append(Catalog.get_card(int(draw_pile.pop_back())))
	return cards

func discard(cards: Array) -> void:
	for card in cards:
		discard_pile.append(int(card.id))

func _shuffle(pile: Array) -> void:
	for i in range(pile.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var value = pile[i]
		pile[i] = pile[j]
		pile[j] = value
