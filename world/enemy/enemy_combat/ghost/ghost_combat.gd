extends "res://world/enemy/enemy_combat/combat_enemy.gd"

func configure_archetype() -> void:
	display_name = "Fantasma"
	max_health = 22
	base_damage = 6

func choose_action() -> String:
	if turns_taken % 3 == 0:
		for other in get_tree().get_nodes_in_group("enemies"):
			if other != self and other.check_is_alive():
				return "guard_others"
	return "weak" if turns_taken % 3 == 2 else "attack"

func strategy_text() -> String:
	return "Protege os outros inimigos. O Fantasma fica exposto quando ergue o escudo do grupo."
