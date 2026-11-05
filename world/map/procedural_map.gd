extends Control

const Style = preload("res://interface/ui_style.gd")
const Generator = preload("res://core/run/run_generator.gd")
const ICONS = {
	"combat": preload("res://assets/map/combat_map_icon.png"),
	"elite": preload("res://assets/map/combat_map_icon.png"),
	"rest": preload("res://assets/map/rest_map_icon.png"),
	"boss": preload("res://assets/map/teacher_map_icon.png")
}
var node_buttons: Dictionary = {}
var node_holders: Dictionary = {}
var offsets: Dictionary = {}
var routes: Control
var title: Label
var status: Label
var footer: Label
var deck_button: Button
var legend: HBoxContainer

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	GameManager.current_context = GameManager.Context.MAP
	if GameManager.map_rows.is_empty():
		GameManager.prepare_run(false)
	Style.background(self, Style.MAP_BACKGROUND)
	routes = preload("res://world/map/map_routes.gd").new()
	routes.buttons = node_buttons
	routes.rows = GameManager.map_rows
	add_child(routes)
	routes.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	title = Style.label("O caminho até o Professor", 28)
	add_child(title)
	status = Style.label("HP %d/%d   •   %d cartas   •   %s" % [GameManager.player_health, GameManager.max_player_health, GameManager.get_run_deck().size(), "Difícil — sem desenhos" if GameManager.hard_mode else "Normal"], 16)
	add_child(status)
	for row in GameManager.map_rows:
		for node in row:
			_create_node(node)
	legend = HBoxContainer.new()
	legend.add_theme_constant_override("separation", 20)
	add_child(legend)
	for kind in ["combat", "rest", "boss"]:
		var icon := TextureRect.new()
		icon.texture = ICONS[kind]
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(32, 32)
		legend.add_child(icon)
		legend.add_child(Style.label({"combat":"Combate / Elite", "rest":"Descanso (+24 HP)", "boss":"Professor"}[kind], 14))
	footer = Style.label("Siga os círculos de lápis. A dificuldade está abaixo de cada encontro.  •  Semente %d" % GameManager.run_seed, 13)
	add_child(footer)
	deck_button = Style.button("Ver baralho", _show_deck)
	add_child(deck_button)
	resized.connect(_layout)
	_layout()

func _create_node(node: Dictionary) -> void:
	var holder := Control.new()
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.size = Vector2(118, 140)
	add_child(holder)
	node_holders[node.id] = holder
	var rng := RandomNumberGenerator.new()
	rng.seed = int(node.seed)
	offsets[node.id] = Vector2(rng.randf_range(-10, 10), rng.randf_range(-15, 15))
	var icon := TextureButton.new()
	icon.texture_normal = ICONS[node.kind]
	icon.ignore_texture_size = true
	icon.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	icon.position = Vector2(15, 0)
	icon.size = Vector2(88, 88)
	if node.kind == "boss":
		icon.position = Vector2(1, -12)
		icon.size = Vector2(116, 112)
	icon.disabled = not GameManager.available_nodes.has(node.id)
	icon.pressed.connect(_select.bind(str(node.id)))
	icon.mouse_entered.connect(func(): if not icon.disabled: icon.modulate = Color(1.0, 0.95, 0.78))
	icon.mouse_exited.connect(func(): if not icon.disabled: icon.modulate = Color.WHITE)
	holder.add_child(icon)
	node_buttons[node.id] = icon
	var kind: String = {"combat":"Combate", "elite":"ELITE", "rest":"Descanso", "boss":"Professor"}[node.kind]
	var caption := Style.label(kind, 14)
	caption.position = Vector2(-9, 88)
	caption.size = Vector2(136, 26)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	holder.add_child(caption)
	var tier := Style.label("+24 HP" if node.kind == "rest" else Generator.TIERS[int(node.tier) - 1], 12)
	tier.position = Vector2(-9, 113)
	tier.size = Vector2(136, 24)
	tier.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	holder.add_child(tier)
	if node.kind == "elite":
		caption.add_theme_color_override("font_color", Color("884e43"))
	var visited: bool = GameManager.visited_nodes.has(node.id)
	if icon.disabled and not visited:
		holder.modulate = Color(0.75, 0.75, 0.75, 0.58)
	icon.tooltip_text = "%s • %s\n%s" % [kind, tier.text, "Concluído" if visited else ("Escolher este caminho" if not icon.disabled else "Siga uma rota adjacente para chegar aqui")]

func _layout() -> void:
	var dimensions := get_viewport_rect().size
	title.position = Vector2(160, 30)
	status.position = Vector2(160, 82)
	var left := dimensions.x * 0.13
	var right := dimensions.x * 0.90
	var top := 215.0
	var bottom := dimensions.y - 228.0
	for row in GameManager.map_rows:
		for node in row:
			var x := lerpf(left, right, float(node.row) / 6.0)
			var y := lerpf(top, bottom, float(node.lane) / 2.0) if node.kind != "boss" else (top + bottom) * 0.5
			node_holders[node.id].position = Vector2(x - 59, y - 44) + offsets[node.id]
	legend.position = Vector2(140, dimensions.y - 112)
	footer.position = Vector2(185, dimensions.y - 54)
	deck_button.position = Vector2(dimensions.x - 290, 32)
	deck_button.size = Vector2(180, 54)
	routes.queue_redraw()

func _select(id: String) -> void:
	GameManager.select_map_node(id)

func _show_deck() -> void:
	add_child(load("res://interface/deck_viewer.gd").new())
