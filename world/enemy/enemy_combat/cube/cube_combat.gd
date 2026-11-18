extends "res://world/enemy/enemy_combat/combat_enemy.gd"

func configure_archetype() -> void:
	display_name = "Cubo"
	max_health = 28
	base_damage = 8
	apply_block = 5

func choose_action() -> String:
	return ["defend", "attack", "charge", "heavy"][turns_taken % 4]

func strategy_text() -> String:
	return "Enquanto tiver escudo, o Cubo reduz em 3 o dano comum. Perfuração evita a redução."

func projectile_damage(damage: int, shot: Dictionary) -> int:
	return maxi(0, damage - 3) if shield > 0 and not shot.pierce else damage
