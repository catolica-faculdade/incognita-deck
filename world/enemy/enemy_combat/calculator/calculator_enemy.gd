extends "res://world/enemy/enemy_combat/combat_enemy.gd"

func configure_archetype() -> void:
	display_name = "Calculadora"
	max_health = 24
	base_damage = 7
	flip_on_attack = true

func choose_action() -> String:
	if health < int(max_health * 0.4) and turns_taken % 3 == 0:
		return "heal"
	return ["weak", "attack", "heavy"][turns_taken % 3]
