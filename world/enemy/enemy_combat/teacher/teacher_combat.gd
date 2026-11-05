extends "res://world/enemy/enemy_combat/combat_enemy.gd"

@export var min_random_scale := 0.65
@export var max_random_scale := 0.85
var teleport_positions := [Vector2(590, -300), Vector2(282, -350), Vector2(800, -250), Vector2(400, -350), Vector2(650, -280)]

func configure_archetype() -> void:
	display_name = "Professor"
	max_health = 65
	base_damage = 8
	poison = 4
	heal_amount = 7
	self_heal_amount = 6

func choose_action() -> String:
	if health < int(max_health * 0.5):
		return ["heavy", "poison", "heal_all", "teleport"][turns_taken % 4]
	return ["teleport", "attack", "poison", "guard_all"][turns_taken % 4]

func after_surviving_hit() -> void:
	anim_sprite.play("teleport")
	_play_sound("TeleportSound")
	await get_tree().create_timer(0.3).timeout
	position = teleport_positions[rng.randi_range(0, teleport_positions.size() - 1)]
	start_position = position
	var random_scale := rng.randf_range(min_random_scale, max_random_scale)
	scale = Vector2(random_scale, random_scale)
	anim_sprite.play("idle")
