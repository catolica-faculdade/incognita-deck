extends RefCounted

const Style = preload("res://interface/ui_style.gd")
const Generator = preload("res://core/run/run_generator.gd")
const Doodle = preload("res://world/enemy/enemy_combat/doodle_enemy.gd")
const DOODLE_SCENE = preload("res://world/enemy/enemy_combat/doodle_enemy.tscn")

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
	background.modulate = Generator.WORLDS[int(spec.get("world", 0))].tint
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
		var scene: PackedScene = ENEMY_SCENES.get(data.archetype, DOODLE_SCENE)
		var enemy = scene.instantiate()
		if enemy is Doodle:
			enemy.archetype = data.archetype
		enemy.position = data.position
		enemy.scale = Vector2(0.62, 0.62)
		enemy.enemy_seed = int(data.seed)
		enemy.difficulty_tier = int(data.tier)
		enemy.elite_unit = data.get("elite", false)
		arena.add_child(enemy)
	for mirror: PackedVector2Array in spec.get("mirrors", []):
		draw_mirror(arena, mirror)
	var music := AudioStreamPlayer.new()
	music.stream = preload("res://assets/music/incognita_deck_combate.mp3")
	music.bus = &"Music"
	music.volume_db = -14.0
	music.autoplay = true
	arena.add_child(music)
	return arena

static func has_archetype(id: String) -> bool:
	return ENEMY_SCENES.has(id) or Doodle.PROFILES.has(id)

static func draw_mirror(arena: Node2D, segment: PackedVector2Array) -> Node2D:
	var outline := Line2D.new()
	outline.points = segment
	outline.width = 10.0
	outline.default_color = Color("27596a")
	outline.antialiased = true
	arena.add_child(outline)
	var glass := Line2D.new()
	glass.points = segment
	glass.width = 4.0
	glass.default_color = Color("bdefff")
	glass.antialiased = true
	outline.add_child(glass)
	var label := Style.readable_label("Espelho", 14)
	label.size.x = 88
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2((segment[0].x + segment[1].x) * 0.5 - label.size.x * 0.5, minf(segment[0].y, segment[1].y) - 24)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_color_override("font_outline_color", Color("fffdf5"))
	label.add_theme_constant_override("outline_size", 4)
	outline.add_child(label)
	return outline
