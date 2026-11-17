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

func strategy_text() -> String:
	return "Use duas cartas matemáticas: disparos mais simples perdem 5 de dano."

func projectile_damage(damage: int, shot: Dictionary) -> int:
	return maxi(0, damage - 5) if shot.math_cards < 2 else damage
