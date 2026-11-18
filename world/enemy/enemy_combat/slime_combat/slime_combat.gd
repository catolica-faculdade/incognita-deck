extends "res://world/enemy/enemy_combat/combat_enemy.gd"

func configure_archetype() -> void:
	display_name = "Slime"
	max_health = 20
	base_damage = 5
	poison = 3

func choose_action() -> String:
	return ["poison", "attack", "defend"][turns_taken % 3]

func strategy_text() -> String:
	return "Envenene primeiro. O Slime envenenado recebe +4 de dano por acerto."

func projectile_damage(damage: int, _shot: Dictionary) -> int:
	return damage + 4 if poison_amount > 0 else damage
