extends RefCounted

const KEYS = ["heal", "shield", "poison", "damage", "pierce", "vulnerable", "cleanse", "thorns", "strength", "reflected_damage", "poison_bonus"]

static func aggregate(cards: Array) -> Dictionary:
	var result := {}
	for key in KEYS:
		result[key] = 0
	for card in cards:
		var effects: Dictionary = card.get("effects", {})
		for key in KEYS:
			result[key] += maxi(int(effects.get(key, 0)), 0)
	if result.poison > 0:
		result.poison += result.poison_bonus
	return result
