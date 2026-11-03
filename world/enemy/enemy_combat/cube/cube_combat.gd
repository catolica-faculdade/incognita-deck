extends "res://world/enemy/enemy_combat/combat_enemy.gd"

func configure_archetype() -> void:
	display_name = "Cubo"
	max_health = 28
	base_damage = 8
	apply_block = 5

func choose_action() -> String:
	return ["defend", "attack", "charge", "heavy"][turns_taken % 4]
