extends RefCounted

const KEYS = ["heal", "shield", "poison", "damage", "pierce", "vulnerable", "cleanse", "thorns", "strength"]

static func aggregate(cards: Array) -> Dictionary:
	var result := {}
	for key in KEYS:
		result[key] = 0
	for card in cards:
		var effects: Dictionary = card.get("effects", {})
		for key in KEYS:
			result[key] += maxi(int(effects.get(key, 0)), 0)
	return result
