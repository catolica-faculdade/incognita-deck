extends "res://world/enemy/enemy_combat/combat_enemy.gd"

func configure_archetype() -> void:
	display_name = "Sentinela"
	max_health = 34
	base_damage = 7
	apply_block = 7
	apply_defend = 12

func choose_action() -> String:
	return ["guard_all", "charge", "heavy"][action_turn() % 3]

func strategy_text() -> String:
	return "Acumula força antes do ataque pesado. Reserve escudo quando ele carregar."
