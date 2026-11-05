extends Control
## HUD compacto original: ícones acima dos valores, sobre painel translúcido.

const Style = preload("res://interface/ui_style.gd")
const HEART = preload("res://assets/interface/hearth_icon.png")
const SHIELD = preload("res://assets/interface/shield_icon.png")
const POISON = preload("res://assets/interface/poison_icon.png")
const THORNS = preload("res://assets/interface/thorns_icon.png")
var labels: Dictionary = {}
var icons: Dictionary = {}
var health_label: Label
var shield_label: Label
var poison_label: Label
var thorns_label: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel := PanelContainer.new()
	panel.name = "StatusPanel"
	var background := StyleBoxFlat.new()
	background.bg_color = Color(0.12, 0.12, 0.12, 0.58)
	background.set_corner_radius_all(3)
	background.content_margin_left = 16
	background.content_margin_right = 16
	background.content_margin_top = 6
	background.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", background)
	add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	panel.add_child(row)
	var textures := {
		"health": _crop(HEART, Rect2(345, 705, 1860, 1520)),
		"shield": _crop(SHIELD, Rect2(360, 655, 1840, 2070)),
		"poison": _crop(POISON, Rect2(450, 600, 1450, 2170)),
		"thorns": THORNS
	}
	for key in ["health", "shield", "poison", "thorns"]:
		var column := VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		column.add_theme_constant_override("separation", 2)
		row.add_child(column)
		var center := CenterContainer.new()
		column.add_child(center)
		var icon := TextureRect.new()
		icon.texture = textures[key]
		icon.custom_minimum_size = Vector2(48, 48)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		center.add_child(icon)
		icons[key] = icon
		var value := Style.readable_label("", 18)
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		value.add_theme_color_override("font_color", Color.WHITE)
		column.add_child(value)
		labels[key] = value
	health_label = labels.health
	shield_label = labels.shield
	poison_label = labels.poison
	thorns_label = labels.thorns
	update_player_info(GameManager.player_health, GameManager.max_player_health)

func _crop(source: Texture2D, region: Rect2) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = source
	atlas.region = region
	return atlas

func update_player_info(health: int, maximum: int, poison: int = 0, shield: int = 0, thorns: int = 0) -> void:
	health_label.text = "HP: %d/%d" % [health, maximum]
	shield_label.text = "Escudo: %d" % shield
	poison_label.text = "Veneno: %d" % poison
	thorns_label.text = "Espinhos: %d" % thorns
