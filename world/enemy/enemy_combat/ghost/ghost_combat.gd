extends "res://world/enemy/enemy_combat/combat_enemy.gd"

func configure_archetype() -> void:
	display_name = "Fantasma"
	max_health = 22
	base_damage = 6

func choose_action() -> String:
	return ["guard_all", "attack", "weak"][turns_taken % 3]
