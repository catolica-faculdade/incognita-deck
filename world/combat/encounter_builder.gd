extends RefCounted

const ENEMY_SCENES = {
	"cube": preload("res://world/enemy/enemy_combat/cube/cube_combat.tscn"),
	"ghost": preload("res://world/enemy/enemy_combat/ghost/ghost_combat.tscn"),
	"calculator": preload("res://world/enemy/enemy_combat/calculator/calculator_combat.tscn"),
	"slime": preload("res://world/enemy/enemy_combat/slime_combat/slime_combat.tscn"),
	"teacher": preload("res://world/enemy/enemy_combat/teacher/teacher_combat.tscn"),
	"sentinel": preload("res://world/enemy/enemy_combat/sentinel/sentinel.tscn"),
	"alchemist": preload("res://world/enemy/enemy_combat/alchemist/alchemist.tscn"),
	"leech": preload("res://world/enemy/enemy_combat/leech/leech.tscn")
}

static func build(spec: Dictionary) -> Node2D:
	var arena := Node2D.new()
	arena.name = "GeneratedEncounter"
	var background := TextureRect.new()
	background.texture = preload("res://assets/backgrounds/background_combat.png")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var backdrop := CanvasLayer.new()
	backdrop.layer = -10
	arena.add_child(backdrop)
	backdrop.add_child(background)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var camera := Camera2D.new()
	camera.position = Vector2(476, -224)
	arena.add_child(camera)
	var player = preload("res://world/player/player.tscn").instantiate()
	player.name = "player"
	arena.add_child(player)
	for data in spec.enemies:
		var enemy = ENEMY_SCENES[data.archetype].instantiate()
		enemy.position = data.position
		enemy.scale = Vector2(0.62, 0.62)
		enemy.enemy_seed = int(data.seed)
		enemy.difficulty_tier = int(data.tier)
		arena.add_child(enemy)
	var music := AudioStreamPlayer.new()
	music.stream = preload("res://assets/music/incognita_deck_combate.mp3")
	music.bus = &"Music"
	music.volume_db = -14.0
	music.autoplay = true
	arena.add_child(music)
	return arena
