extends "res://world/enemy/enemy_combat/combat_enemy.gd"

func configure_archetype() -> void:
	display_name = "Sentinela"
	max_health = 34
	base_damage = 7
	apply_block = 7
	apply_defend = 12

func choose_action() -> String:
	return ["guard_all", "charge", "heavy"][turns_taken % 3]
