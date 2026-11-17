extends RefCounted
## Toda a run é sorteada uma vez. Voltar ao mapa não muda as opções nem os encontros.

const WORLDS := [
	{"name":"O Plano Cartesiano", "stages":6, "boss":"Professor", "boss_id":"teacher", "tint":Color.WHITE},
	{"name":"Sala de Aula", "stages":7, "boss":"Alunos", "boss_id":"students", "tint":Color("eee8dd")},
	{"name":"Diretoria", "stages":8, "boss":"Diretor", "boss_id":"principal", "tint":Color("e3e9ed")}
]
const TOTAL_STAGES := 22
const TIERS = ["Leve", "Moderado", "Desafiador", "Difícil", "Extremo"]
const POOLS = [
	["slime", "cube", "ghost", "pencil"],
	["ruler", "notebook", "eraser", "calculator"],
	["leech", "clip", "protractor", "stapler"]
]
const ELITE_POOLS = [
	["sentinel", "alchemist"],
	["scissors", "compass", "sentinel"],
	["clock", "compass", "alchemist"]
]

static func generate(run_seed: int, world: int = 0) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = run_seed + world * 104729
	var stages: int = WORLDS[world].stages
	var rows: Array = []
	for row in range(stages):
		var nodes: Array = []
		var boss := row == stages - 1
		var has_challenging_opening := false
		for lane in range(1 if boss else 3):
			var tier := clampi(1 + world + floori(row / 3.0) + rng.randi_range(0, 1), 1, 5)
			var kind := "boss" if boss else "combat"
			if not boss and row > 0:
				var roll := rng.randf()
				if (row == stages - 2 and lane == 1) or roll < 0.16:
					kind = "rest"
				elif row >= 2 and roll > 0.76:
					kind = "elite"
					tier = mini(tier + 1, 5)
				elif roll < 0.25:
					kind = "event"
			if boss:
				tier = 3 + world
			var node_seed := int(rng.randi())
			if row == 0:
				tier = 1
			elif row == 1:
				var opening_roll := node_seed % 100
				tier = 1 if opening_roll < 40 else 2
				if opening_roll >= 80 and kind != "rest" and not has_challenging_opening:
					tier = 3
					has_challenging_opening = true
			var rules := arena_rules(world, row, kind, node_seed)
			nodes.append({"id": "%d:%d:%d" % [world, row, lane], "world": world, "row": row, "lane": lane,
				"kind": kind, "tier": tier, "seed": node_seed, "mirror": rules.mirror,
				"barrier": rules.barrier, "shift": rules.shift, "next": []})
		rows.append(nodes)
	for row in range(stages - 1):
		for node in rows[row]:
			for next in rows[row + 1]:
				if row == stages - 2 or absi(int(node.lane) - int(next.lane)) <= 1:
					node.next.append(next.id)
	return rows

static func arena_rules(world: int, row: int, kind: String, seed_value: int) -> Dictionary:
	var eligible := kind in ["combat", "elite"] and row >= 1
	return {
		"shift": eligible and world == 0 and seed_value % 100 < 16 + row * 9,
		"mirror": eligible and world >= 1 and seed_value % 100 < 20 + world * 7 + row * 6,
		"barrier": eligible and world == 2 and row >= 2 and floori(seed_value / 100.0) % 100 < 17 + row * 8
	}

static func arena_label(node: Dictionary) -> String:
	var labels: Array[String] = []
	if node.get("shift", false):
		labels.append("Alvo móvel")
	if node.get("mirror", false):
		labels.append("Espelho")
	if node.get("barrier", false):
		labels.append("Barreira")
	return " + ".join(labels)

static func encounter(node: Dictionary) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(node.seed)
	var tier := int(node.tier)
	var world := int(node.get("world", 0))
	var depth := int(node.get("row", 0))
	for previous in range(world):
		depth += int(WORLDS[previous].stages)
	if node.kind == "final":
		depth = TOTAL_STAGES - 1
	var final: bool = node.kind == "final"
	var boss: bool = node.kind == "boss" or final
	var count := 2 if tier < 4 else 3
	if tier == 5 and not boss and rng.randf() > 0.75:
		count = 4
	if boss:
		count = 3 if final else 2
	var boss_id: String = "exam" if final else WORLDS[world].boss_id
	var boss_name: String = "ENEM" if final else WORLDS[world].boss
	var slots: Array = [Vector2(230, -260), Vector2(455, -355), Vector2(660, -280), Vector2(820, -345)]
	# Sorteia alturas, distâncias e composição, sem reutilizar cenas de fases prontas.
	var enemies: Array = []
	for i in range(count):
		var elite: bool = node.kind == "elite" and i == 0
		var pool: Array = ELITE_POOLS[world] if elite else POOLS[world]
		var archetype: String = pool[rng.randi_range(0, pool.size() - 1)]
		if boss and i == count - 1:
			archetype = boss_id
		var pos: Vector2 = slots[i] + Vector2(rng.randf_range(-25, 25), rng.randf_range(-30, 30))
		pos.y = clampf(pos.y, -370.0, -250.0)
		enemies.append({"archetype": archetype, "position": pos, "tier": tier, "seed": int(rng.randi()), "elite": elite, "depth": depth})
	var mirrors: Array[PackedVector2Array] = []
	if node.get("mirror", false):
		var center := Vector2(350, -259)
		var half_segment := Vector2(29, -29 if int(node.seed) % 2 == 0 else 29)
		mirrors.append(PackedVector2Array([center - half_segment, center + half_segment]))
	var barriers: Array[PackedVector2Array] = []
	if node.get("barrier", false):
		var middle_y := -310.0 if int(node.seed) % 2 == 0 else -225.0
		barriers.append(PackedVector2Array([Vector2(550, middle_y - 44), Vector2(550, middle_y + 44)]))
	return {"seed": int(node.seed), "tier": tier, "world": world, "boss": boss, "boss_name": boss_name if boss else "",
		"kind": node.kind, "enemies": enemies, "mirrors": mirrors, "barriers": barriers,
		"shift": node.get("shift", false), "arena_label": arena_label(node)}

static func find_node(rows: Array, id: String) -> Dictionary:
	for row in rows:
		for node in row:
			if node.id == id:
				return node
	return {}
