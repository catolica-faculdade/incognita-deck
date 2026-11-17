extends "res://world/enemy/enemy_combat/combat_enemy.gd"

const PROFILES := {
	"pencil": {"name":"Lápis", "hp":19, "damage":6, "actions":["attack", "charge", "defend"]},
	"ruler": {"name":"Régua", "hp":26, "damage":7, "actions":["defend", "attack", "weak", "attack"]},
	"notebook": {"name":"Caderno", "hp":27, "damage":6, "actions":["guard_all", "attack", "heal_all", "attack"]},
	"eraser": {"name":"Borracha", "hp":23, "damage":7, "actions":["weak", "attack", "heal", "attack"]},
	"clip": {"name":"Clipe", "hp":26, "damage":7, "actions":["guard_all", "attack", "charge", "attack"]},
	"protractor": {"name":"Transferidor", "hp":28, "damage":8, "actions":["attack", "weak", "defend", "heavy"]},
	"stapler": {"name":"Grampeador", "hp":29, "damage":8, "actions":["charge", "attack", "defend", "heavy"]},
	"scissors": {"name":"Tesoura", "hp":30, "damage":8, "actions":["attack", "heavy", "defend", "weak", "charge"]},
	"compass": {"name":"Compasso", "hp":33, "damage":8, "actions":["mirror", "attack", "guard_all", "heavy", "weak"]},
	"clock": {"name":"Relógio", "hp":35, "damage":9, "actions":["charge", "attack", "heavy", "defend", "weak"]},
	"students": {"name":"Alunos", "hp":66, "damage":8, "actions":["guard_all", "mirror", "attack", "heal_all", "heavy"], "boss":true, "support":"guard_all"},
	"principal": {"name":"Diretor", "hp":80, "damage":9, "actions":["defend", "mirror", "pressure", "guard_all", "heavy"], "boss":true, "support":"defend"},
	"exam": {"name":"ENEM", "hp":96, "damage":9, "actions":["mirror", "weak", "attack", "heavy", "guard_all", "pressure"], "boss":true, "support":"mirror"}
}

var archetype := ""
var actions: Array = []

func configure_archetype() -> void:
	var profile: Dictionary = PROFILES[archetype]
	display_name = profile.name
	max_health = profile.hp
	base_damage = profile.damage
	actions = profile.actions
	var art := load("res://assets/enemies/doodle/%s.png" % archetype) as Texture2D
	var frames := SpriteFrames.new()
	for animation in [&"idle", &"attack", &"hit"]:
		frames.add_animation(animation)
		frames.add_frame(animation, art)
	anim_sprite.sprite_frames = frames
	var target_size := 205.0 if profile.get("boss", false) else 168.0
	anim_sprite.scale = Vector2.ONE * target_size / maxf(art.get_width(), art.get_height())

func choose_action() -> String:
	var turn := action_turn()
	if health <= max_health / 3.0 and PROFILES[archetype].get("boss", false):
		return ["pressure", "mirror", "heavy"][turn % 3]
	return actions[turn % actions.size()]

func choose_follow_up(first: String) -> String:
	var support: String = PROFILES[archetype].get("support", "")
	if support.is_empty() or turns_taken % 3 == 2:
		return ""
	if first != support:
		return support
	return "guard_all" if first == "defend" else "defend"
