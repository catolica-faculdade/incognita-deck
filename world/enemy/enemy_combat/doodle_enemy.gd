extends "res://world/enemy/enemy_combat/combat_enemy.gd"

const PROFILES := {
	"pencil": {"name":"Lápis", "hp":19, "damage":6, "actions":["attack", "charge", "defend"]},
	"ruler": {"name":"Régua", "hp":26, "damage":7, "actions":["defend", "attack", "weak", "attack"]},
	"notebook": {"name":"Caderno", "hp":27, "damage":6, "actions":["guard_all", "attack", "defend", "attack"]},
	"eraser": {"name":"Borracha", "hp":23, "damage":7, "actions":["weak", "attack", "heal", "attack"]},
	"clip": {"name":"Clipe", "hp":26, "damage":7, "actions":["guard_all", "attack", "charge", "attack"]},
	"protractor": {"name":"Transferidor", "hp":28, "damage":8, "actions":["attack", "weak", "defend", "heavy"]},
	"stapler": {"name":"Grampeador", "hp":29, "damage":8, "actions":["charge", "attack", "defend", "heavy"]},
	"scissors": {"name":"Tesoura", "hp":30, "damage":8, "actions":["attack", "heavy", "defend", "weak", "charge"]},
	"compass": {"name":"Compasso", "hp":33, "damage":8, "actions":["mirror", "attack", "guard_all", "heavy", "weak"]},
	"clock": {"name":"Relógio", "hp":35, "damage":9, "actions":["charge", "attack", "clock_strike", "defend", "weak"]},
	"students": {"name":"Alunos", "hp":66, "damage":8, "actions":["guard_all", "mirror", "attack", "heal_all", "heavy"], "boss":true, "support":"guard_all"},
	"principal": {"name":"Diretor", "hp":80, "damage":9, "actions":["defend", "mirror", "pressure", "guard_all", "heavy"], "boss":true, "support":"defend"},
	"exam": {"name":"ENEM", "hp":96, "damage":9, "actions":["mirror", "weak", "attack", "heavy", "guard_all", "pressure"], "boss":true, "support":"mirror"}
}

var archetype := ""
var actions: Array = []
const STRATEGIES := {
	"pencil": "Fica mais forte quando perde metade da vida. Finalize antes de deixá-lo carregar.",
	"ruler": "Reduz em 4 o dano de trajetórias retas. Uma curva contorna a defesa.",
	"notebook": "Cura o grupo quando um aliado está muito ferido. Concentre o dano ou elimine o Caderno.",
	"eraser": "Pode apagar veneno e vulnerabilidade. Ataque diretamente quando ela anunciar a limpeza.",
	"clip": "Protege os companheiros. Quando fica sozinho, começa a acumular força.",
	"protractor": "Recebe +5 de dano de disparos refletidos. Use um espelho ou Reflexão em X.",
	"stapler": "Amortece golpes de até 10 de dano em 4. Some cartas de dano em um disparo forte.",
	"scissors": "Apara 5 de dano de composições com três ou mais cartas matemáticas. Prepare um percurso curto.",
	"compass": "Coloca espelhos duradouros. Veja a trajetória prevista antes de confirmar.",
	"clock": "A Badalada cresce com o tempo de combate. Derrote o Relógio cedo ou guarde escudo.",
	"students": "Protegem e curam o grupo. Desgaste os Alunos com veneno e perfuração.",
	"principal": "Alterna escudo, espelhos e pressão. Use perfuração nos turnos de escudo.",
	"exam": "Usa espelhos e fraqueza para mudar a jogada. Revise o percurso após cada turno."
}

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
	match archetype:
		"pencil":
			if health * 2 <= max_health and strength == 0:
				return "charge"
		"notebook":
			if turn % 3 == 2:
				for ally in get_tree().get_nodes_in_group("enemies"):
					if ally != self and ally.check_is_alive() and ally.health * 2 < ally.max_health:
						return "heal_all"
				return "attack"
		"eraser":
			if turn % 2 == 0 and (poison_amount > 0 or vulnerable > 0):
				return "cleanse_self"
		"clip":
			if turn % 3 == 0 and get_tree().get_nodes_in_group("enemies").size() == 1:
				return "charge"
	if health <= max_health / 3.0 and PROFILES[archetype].get("boss", false):
		return ["pressure", "mirror", "heavy"][turn % 3]
	return actions[turn % actions.size()]

func strategy_text() -> String:
	return STRATEGIES.get(archetype, "")

func projectile_damage(damage: int, shot: Dictionary) -> int:
	if archetype == "ruler" and not shot.curved:
		return maxi(0, damage - 4)
	if archetype == "protractor" and shot.reflected:
		return damage + 5
	if archetype == "stapler" and damage <= 10:
		return maxi(0, damage - 4)
	if archetype == "scissors" and shot.math_cards >= 3:
		return maxi(0, damage - 5)
	return damage

func choose_follow_up(first: String) -> String:
	var support: String = PROFILES[archetype].get("support", "")
	if support.is_empty() or turns_taken % 3 == 2:
		return ""
	if first != support:
		return support
	return "guard_all" if first == "defend" else "defend"
