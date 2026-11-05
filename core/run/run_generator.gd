extends RefCounted
## Toda a run é sorteada uma vez. Voltar ao mapa não muda as opções nem os encontros.

const ROW_COUNT := 7
const TIERS = ["Leve", "Moderado", "Desafiador", "Difícil", "Extremo"]
const POOLS = [
	["slime", "cube", "ghost"],
	["slime", "cube", "ghost", "calculator", "leech"],
	["cube", "ghost", "calculator", "sentinel", "alchemist", "leech"]
]

static func generate(run_seed: int) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = run_seed
	var rows: Array = []
	for row in range(ROW_COUNT):
		var nodes: Array = []
		for lane in range(1 if row == ROW_COUNT - 1 else 3):
			var boss := row == ROW_COUNT - 1
			var tier := clampi(1 + int(row / 2.0) + rng.randi_range(0, 1), 1, 5)
			var kind := "boss" if boss else "combat"
			if not boss and row > 0:
				var roll := rng.randf()
				if (row == 4 and lane == 1) or roll < 0.16:
					kind = "rest"
				elif row >= 2 and roll > 0.76:
					kind = "elite"
					tier = mini(tier + 1, 5)
			if boss:
				tier = 5
			nodes.append({"id": "%d:%d" % [row, lane], "row": row, "lane": lane,
				"kind": kind, "tier": tier, "seed": int(rng.randi()), "next": []})
		rows.append(nodes)
	for row in range(ROW_COUNT - 1):
		for node in rows[row]:
			for next in rows[row + 1]:
				if row == ROW_COUNT - 2 or absi(int(node.lane) - int(next.lane)) <= 1:
					node.next.append(next.id)
	return rows

static func encounter(node: Dictionary) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(node.seed)
	var tier := int(node.tier)
	var boss: bool = node.kind == "boss"
	var count := 2 if tier < 3 else 3
	if tier >= 4 and rng.randf() > 0.45:
		count = 4
	if boss:
		count = 3
	var slots: Array = [Vector2(230, -260), Vector2(455, -355), Vector2(660, -280), Vector2(820, -345)]
	# Sorteia alturas, distâncias e composição, sem reutilizar cenas de fases prontas.
	var enemies: Array = []
	for i in range(count):
		var pool: Array = POOLS[mini(tier - 1, POOLS.size() - 1)]
		var archetype: String = pool[rng.randi_range(0, pool.size() - 1)]
		if boss:
			archetype = "teacher" if i == count - 1 else ("sentinel" if i == 0 else "alchemist")
		var pos: Vector2 = slots[i] + Vector2(rng.randf_range(-25, 25), rng.randf_range(-30, 30))
		pos.y = clampf(pos.y, -370.0, -250.0)
		enemies.append({"archetype": archetype, "position": pos, "tier": tier, "seed": int(rng.randi())})
	return {"seed": int(node.seed), "tier": tier, "boss": boss, "kind": node.kind, "enemies": enemies}

static func find_node(rows: Array, id: String) -> Dictionary:
	for row in rows:
		for node in row:
			if node.id == id:
				return node
	return {}
