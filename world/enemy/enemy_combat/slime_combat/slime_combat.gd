extends "res://world/enemy/enemy_combat/combat_enemy.gd"

func configure_archetype() -> void:
	display_name = "Slime"
	max_health = 20
	base_damage = 5
	poison = 3

func choose_action() -> String:
	return ["poison", "attack", "defend"][turns_taken % 3]
