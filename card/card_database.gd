extends RefCounted
## IDs são persistentes dentro da run. Dados retornados são cópias independentes.

const STARTER_DECK = [1, 1, 2, 3, 4, 5, 7, 16, 17, 17, 18, 19]
const SPIRAL_REPEAT_LIMIT := 2
const REPEAT_HIT_DAMAGE := 0.70
const CARDS = [
	{"id":1,"name":"Avanço","type":"linear","x":8.0,"y":0.0,"energy_cost":1},
	{"id":2,"name":"Elevar","type":"diagonal","x":5.0,"y":2.0,"energy_cost":1},
	{"id":3,"name":"Arco","type":"quadratic","coefficient":"a","value":0.35,"energy_cost":1},
	{"id":4,"name":"Queda","type":"quadratic","coefficient":"a","value":-0.35,"energy_cost":1},
	{"id":5,"name":"Onda","type":"special","special_type":"wave","amplitude":3.0,"frequency":4.0,"length":12.0,"energy_cost":2},
	{"id":6,"name":"Salto","type":"linear","x":0.0,"y":2.0,"energy_cost":1},
	{"id":7,"name":"Degrau","type":"linear","x":3.0,"y":0.0,"energy_cost":1},
	{"id":8,"name":"Impulso","type":"diagonal","x":4.0,"y":2.0,"energy_cost":1},
	{"id":9,"name":"Colina","type":"quadratic","coefficient":"a","value":0.20,"energy_cost":1},
	{"id":10,"name":"Mergulho","type":"quadratic","coefficient":"a","value":-0.20,"energy_cost":1},
	{"id":11,"name":"Oscilar","type":"special","special_type":"wave","amplitude":1.5,"frequency":2.0,"length":4.0,"energy_cost":1},
	{"id":12,"name":"Maré","type":"special","special_type":"wave","amplitude":1.5,"frequency":2.0,"length":8.0,"energy_cost":1},
	{"id":13,"name":"Ascensão","type":"diagonal","x":3.0,"y":2.0,"energy_cost":1},
	{"id":14,"name":"Travessia","type":"linear","x":4.0,"y":0.0,"energy_cost":1},
	{"id":15,"name":"Vale","type":"quadratic","coefficient":"c","value":-2.0,"energy_cost":1},
	{"id":16,"name":"Remendo","type":"effect","energy_cost":1,"icon":"heal","effects":{"heal":5}},
	{"id":17,"name":"Guarda","type":"effect","energy_cost":1,"icon":"shield","effects":{"shield":7}},
	{"id":18,"name":"Tinta tóxica","type":"effect","energy_cost":1,"icon":"poison","effects":{"poison":4}},
	{"id":19,"name":"Giz afiado","type":"effect","energy_cost":1,"icon":"attack","effects":{"damage":8}},
	{"id":20,"name":"Antídoto","type":"effect","energy_cost":1,"icon":"heal","effects":{"cleanse":1,"heal":3}},
	{"id":21,"name":"Muralha","type":"effect","energy_cost":2,"icon":"shield","rare":true,"effects":{"shield":16}},
	{"id":22,"name":"Recuperação","type":"effect","energy_cost":2,"icon":"heal","rare":true,"effects":{"heal":12}},
	{"id":23,"name":"Contágio","type":"effect","energy_cost":2,"icon":"poison","rare":true,"effects":{"poison":9}},
	{"id":24,"name":"Compasso","type":"effect","energy_cost":2,"icon":"attack","rare":true,"effects":{"damage":12,"pierce":1}},
	{"id":25,"name":"Espinhos","type":"effect","energy_cost":1,"icon":"thorns","effects":{"shield":4,"thorns":4}},
	{"id":26,"name":"Ponto fraco","type":"effect","energy_cost":1,"icon":"attack","effects":{"vulnerable":2}},
	{"id":27,"name":"Concentração","type":"effect","energy_cost":1,"icon":"attack","effects":{"strength":3}},
	{"id":28,"name":"Abrigo","type":"effect","energy_cost":2,"icon":"heal","effects":{"heal":6,"shield":8}},
	{"id":29,"name":"Descida","type":"diagonal","x":5.0,"y":-2.0,"energy_cost":1},
	{"id":30,"name":"Rampa","type":"quadratic","coefficient":"b","value":0.5,"energy_cost":1},
	{"id":31,"name":"Espiral","type":"spiral","turns":4,"radius":3.0,"energy_cost":2,"rare":true},
	{"id":32,"name":"Reflexão em X","type":"reflection","energy_cost":1},
	{"id":33,"name":"Rotação","type":"rotation","degrees":15,"icon":"diagonal","energy_cost":1},
	{"id":34,"name":"Fenda","type":"modifier","icon":"linear","energy_cost":1},
	{"id":35,"name":"Prisma","type":"effect","icon":"attack","energy_cost":1,"rare":true,"effects":{"reflected_damage":7}},
	{"id":36,"name":"Catalisador","type":"effect","icon":"poison","energy_cost":1,"effects":{"poison_bonus":3}}
]

static func get_card(id: int) -> Dictionary:
	for card in CARDS:
		if int(card.id) == id:
			return card.duplicate(true)
	return {}

static func reward_choices(reward_seed: int, count: int = 3, guarantee_rare: bool = false) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = reward_seed
	var pool: Array = CARDS.duplicate(true)
	var result: Array = []
	if guarantee_rare and count > 0:
		var rares := pool.filter(func(card: Dictionary): return card.get("rare", false))
		if not rares.is_empty():
			var rare: Dictionary = rares[rng.randi_range(0, rares.size() - 1)]
			result.append(rare)
			pool.erase(rare)
	for i in range(mini(count - result.size(), pool.size())):
		result.append(pool.pop_at(rng.randi_range(0, pool.size() - 1)))
	return result

static func math_text(card: Dictionary) -> String:
	match card.type:
		"linear", "diagonal":
			return "Δx = %.1f\nΔy = %.1f" % [float(card.x), float(card.y)]
		"quadratic":
			var power: String = {"a":"x²", "b":"x", "c":""}[card.coefficient]
			return "Δy = %.2f%s" % [float(card.value), power]
		"special":
			return "Δy = %s·sen(kx)\nk = %sπ/%s" % [str(card.amplitude).trim_suffix(".0"), str(2.0 * float(card.frequency)).trim_suffix(".0"), str(card.length).trim_suffix(".0")]
		"spiral":
			return "r = %.0fθ/(%dπ)\nθ ∈ [0, %dπ]" % [card.radius, int(card.turns) * 2, int(card.turns) * 2]
		"reflection":
			return "(x, y) → (x, −y)"
		"rotation":
			return "Gira %d°" % card.degrees
		"modifier":
			return "Atravessa barreiras"
	var effects: Dictionary = card.get("effects", {})
	var lines: Array[String] = []
	for key in effects:
		var amount := int(effects[key])
		match key:
			"heal": lines.append("HP + %d" % amount)
			"shield": lines.append("Escudo + %d" % amount)
			"poison": lines.append("Veneno + %d" % amount)
			"damage": lines.append("Dano + %d" % amount)
			"reflected_damage": lines.append("+%d se refletir" % amount)
			"poison_bonus": lines.append("Veneno +%d\nEm combo" % amount)
			"pierce": lines.append("Ignora escudo")
			"cleanse": lines.append("Veneno = 0")
			"vulnerable": lines.append("Vulnerável: %d" % amount)
			"strength": lines.append("Força + %d" % amount)
			"thorns": lines.append("Retorno: %d" % amount)
	return "\n".join(lines)

static func description(card: Dictionary) -> String:
	if card.type == "effect":
		var target := "Nos alvos atingidos pela trajetória." if hits_targets(card) else "Em você, ao confirmar o turno."
		var rules := ""
		var effects: Dictionary = card.get("effects", {})
		if effects.has("shield"):
			rules += "\nEscudo expira no início do seu próximo turno."
		if effects.has("poison"):
			rules += "\nVeneno ignora escudo; causa dano no início do turno do alvo e perde 1 carga."
		if effects.has("vulnerable"):
			rules += "\nVulnerável: recebe 50% mais dano de ataques; perde 1 carga ao agir."
		if effects.has("strength"):
			rules += "\nForça aumenta todos os seus ataques até o fim do combate."
		if effects.has("thorns"):
			rules += "\nRetorna dano a cada atacante até o seu próximo turno."
		if effects.has("reflected_damage"):
			rules += "\nCombine com Reflexão em X ou acerte um espelho."
		if effects.has("poison_bonus"):
			rules += "\nCombine com outra carta que aplique veneno."
		return math_text(card) + "\n" + target + rules
	match card.type:
		"linear", "diagonal": return "Desloca o ponto final da trajetória."
		"quadratic": return "Soma o coeficiente em y = ax² + bx + c."
		"special": return "Soma uma onda: A · sen(2π · f · x/L)."
		"spiral":
			return "Acrescenta %d voltas ao fim do percurso, com raio de %.0f unidades.\nPor inimigo: primeiro acerto com dano integral e até %d adicionais com %d%% do dano." % [
				card.turns, card.radius, SPIRAL_REPEAT_LIMIT, roundi(REPEAT_HIT_DAMAGE * 100.0)
			]
		"reflection": return "Reflete o percurso montado até aqui em torno do eixo X. Precisa de uma trajetória."
		"rotation": return "Gira o percurso montado ao redor da origem em %d° no sentido anti-horário." % card.degrees
		"modifier": return "O disparo atravessa barreiras da arena e continua ricocheteando nos espelhos."
	return ""

static func hits_targets(card: Dictionary) -> bool:
	var effects: Dictionary = card.get("effects", {})
	return effects.has("poison") or effects.has("damage") or effects.has("vulnerable") or effects.has("pierce") or effects.has("poison_bonus") or effects.has("reflected_damage")
