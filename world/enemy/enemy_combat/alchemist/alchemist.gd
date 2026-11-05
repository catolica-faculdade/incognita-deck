extends "res://world/enemy/enemy_combat/combat_enemy.gd"

func configure_archetype() -> void:
	display_name = "Alquimista"
	max_health = 26
	base_damage = 5
	poison = 4
	heal_amount = 6

func choose_action() -> String:
	if turns_taken % 2 == 1:
		for ally in get_tree().get_nodes_in_group("enemies"):
			if ally.check_is_alive() and ally.health < int(ally.max_health * 0.7):
				return "heal_all"
	return ["poison", "weak", "attack"][turns_taken % 3]
