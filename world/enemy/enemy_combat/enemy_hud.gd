extends Node2D

const Style = preload("res://interface/ui_style.gd")

var health_bar: ProgressBar
var body_hover: Control
var max_health := 1
var health := 1
var shield := 0
var hover_info: Control
var health_label: Label
var shield_label: Label
var name_label: Label
var poison_marker: Control
var poison_label: Label

func _ready() -> void:
	body_hover = Control.new()
	body_hover.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(body_hover)
	health_bar = ProgressBar.new()
	health_bar.size = Vector2(112, 10)
	health_bar.show_percentage = false
	health_bar.mouse_filter = Control.MOUSE_FILTER_PASS
	var background := StyleBoxFlat.new()
	background.bg_color = Color("f7f1e5")
	background.border_color = Color("34312b")
	background.set_border_width_all(1)
	background.set_corner_radius_all(3)
	var fill := background.duplicate() as StyleBoxFlat
	fill.bg_color = Color("c97373")
	health_bar.add_theme_stylebox_override("background", background)
	health_bar.add_theme_stylebox_override("fill", fill)
	add_child(health_bar)
	health_bar.size = Vector2(112, 10)

	hover_info = Control.new()
	hover_info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hover_info.visible = false
	add_child(hover_info)
	health_label = _label(Vector2(0, -25), Vector2(70, 24))
	var shield_icon := TextureRect.new()
	shield_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	var shield_texture := AtlasTexture.new()
	shield_texture.atlas = preload("res://assets/interface/shield_icon.png")
	shield_texture.region = Rect2(360, 655, 1840, 2070)
	shield_icon.texture = shield_texture
	shield_icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	shield_icon.position = Vector2(76, -25)
	shield_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shield_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	shield_icon.size = Vector2(22, 22)
	shield_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hover_info.add_child(shield_icon)
	shield_icon.size = Vector2(22, 22)
	shield_label = _label(Vector2(100, -25), Vector2(56, 24))
	name_label = _label(Vector2.ZERO, Vector2(180, 24))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	poison_marker = Control.new()
	poison_marker.position = Vector2(118, -7)
	poison_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	poison_marker.visible = false
	add_child(poison_marker)
	var poison_icon := TextureRect.new()
	poison_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	var poison_texture := AtlasTexture.new()
	poison_texture.atlas = preload("res://assets/interface/poison_icon.png")
	poison_texture.region = Rect2(450, 600, 1450, 2170)
	poison_icon.texture = poison_texture
	poison_icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	poison_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	poison_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	poison_marker.add_child(poison_icon)
	poison_icon.size = Vector2(24, 24)
	poison_label = _label(Vector2(26, 0), Vector2(48, 24))
	poison_label.reparent(poison_marker, false)
	for target in [body_hover, health_bar]:
		target.mouse_entered.connect(_update_hover.call_deferred)
		target.mouse_exited.connect(_update_hover.call_deferred)

func _label(at: Vector2, dimensions: Vector2) -> Label:
	var label := Style.readable_label("", 16)
	label.position = at
	label.size = dimensions
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_color_override("font_outline_color", Color("fffdf5"))
	label.add_theme_constant_override("outline_size", 3)
	hover_info.add_child(label)
	return label

func _update_hover() -> void:
	var target := get_viewport().gui_get_hovered_control()
	hover_info.visible = target == body_hover or target == health_bar

func setup(current: int, maximum: int) -> void:
	max_health = maximum
	health_bar.max_value = maximum
	update_hp(current)

func track_body(bounds: Rect2) -> void:
	body_hover.position = to_local(bounds.position)
	body_hover.size = bounds.size
	name_label.position = body_hover.position + Vector2((body_hover.size.x - name_label.size.x) * 0.5, body_hover.size.y + 8)

func update_hp(current: int) -> void:
	health = current
	health_bar.value = current
	_refresh_values()

func update_shield(amount: int) -> void:
	shield = amount
	var fill := health_bar.get_theme_stylebox("fill") as StyleBoxFlat
	fill.bg_color = Color("619fce") if shield > 0 else Color("c97373")
	_refresh_values()

func update_name(enemy_name: String) -> void:
	name_label.text = enemy_name

func update_poison(amount: int) -> void:
	poison_marker.visible = amount > 0
	poison_label.text = str(amount)

func _refresh_values() -> void:
	health_label.text = "%d/%d" % [health, max_health]
	shield_label.text = str(shield)
