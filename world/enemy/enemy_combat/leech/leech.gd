extends "res://world/enemy/enemy_combat/combat_enemy.gd"

func configure_archetype() -> void:
	display_name = "Sanguessuga"
	max_health = 25
	base_damage = 7

func choose_action() -> String:
	if health < int(max_health * 0.5) and turns_taken % 2 == 0:
		return "heavy"
	return "drain" if turns_taken % 3 != 2 else "defend"
