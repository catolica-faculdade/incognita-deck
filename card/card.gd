extends Control

signal card_played(card)
signal card_removed(card)
signal card_hovered
signal card_exited

const Catalog = preload("res://card/card_database.gd")
const Style = preload("res://interface/ui_style.gd")
const SYMBOLS = {
	"linear": preload("res://assets/cards/general/symbol_forward.png"),
	"diagonal": preload("res://assets/cards/general/symbol_up.png"),
	"quadratic": preload("res://assets/cards/general/symbol_arc.png"),
	"special": preload("res://assets/cards/general/symbol_wave.png"),
	"heal": preload("res://assets/interface/hearth_icon.png"),
	"shield": preload("res://assets/interface/shield_icon.png"),
	"poison": preload("res://assets/interface/poison_icon.png"),
	"thorns": preload("res://assets/interface/thorns_icon.png"),
	"attack": preload("res://assets/cards/general/symbol_forward.png")
}

var card_data: Dictionary = {}
var interaction_enabled := false
var is_played := false
var hard_mode := false
var dragging := false
var drag_offset := Vector2.ZERO
var original_position := Vector2.ZERO
var drop_zone: Control
var tween: Tween
var symbol: TextureRect
var texture_rect: TextureRect
var title: Label
var value: Label
var cost_badge: Panel
var cost_label: Label
var target_label: Label

func _ready() -> void:
	custom_minimum_size = Vector2(128, 196)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_STOP
	var paper := Panel.new()
	var plain_card := StyleBoxFlat.new()
	plain_card.bg_color = Color("fffdf5")
	plain_card.border_color = Style.INK
	plain_card.set_border_width_all(1)
	paper.add_theme_stylebox_override("panel", plain_card)
	add_child(paper)
	paper.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	texture_rect = TextureRect.new()
	texture_rect.texture = preload("res://assets/cards/general/card_default.jpeg")
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
	add_child(texture_rect)
	texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	title = _label(Vector2(8, 9), Vector2(112, 28), 15)
	title.autowrap_mode = TextServer.AUTOWRAP_OFF
	title.clip_text = true
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	cost_badge = Panel.new()
	cost_badge.position = Vector2(114, -14)
	cost_badge.size = Vector2(28, 28)
	var badge_style := StyleBoxFlat.new()
	badge_style.bg_color = Color("f3ca63")
	badge_style.border_color = Color("92681e")
	badge_style.set_border_width_all(1)
	badge_style.set_corner_radius_all(14)
	cost_badge.add_theme_stylebox_override("panel", badge_style)
	cost_badge.z_index = 2
	add_child(cost_badge)
	cost_label = _label(Vector2(114, -14), Vector2(28, 28), 18)
	cost_label.z_index = 3
	symbol = TextureRect.new()
	symbol.position = Vector2(43, 42)
	symbol.size = Vector2(42, 42)
	symbol.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	symbol.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(symbol)
	value = _label(Vector2(7, 88), Vector2(114, 70), 17)
	target_label = _label(Vector2(6, 163), Vector2(116, 25), 11)
	for child in get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_exit)

func _label(at: Vector2, dimensions: Vector2, font_size: int) -> Label:
	var node := Style.label("", font_size)
	node.add_theme_font_override("font", Style.readable())
	node.position = at
	node.size = dimensions
	node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	node.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(node)
	return node

func setup(data: Dictionary, hide_illustrations: bool = GameManager.hard_mode) -> void:
	card_data = data.duplicate(true)
	title.text = card_data.name
	cost_label.text = str(card_data.energy_cost)
	cost_label.tooltip_text = "Custo em energia"
	value.text = Catalog.math_text(card_data)
	_fit_text(title, 15, 11)
	_fit_text(value, 17, 12)
	var key: String = card_data.get("icon", card_data.type)
	symbol.texture = SYMBOLS.get(key)
	target_label.text = "NOS ALVOS" if Catalog.hits_targets(card_data) else ("EM VOCÊ" if card_data.type == "effect" else "TRAJETÓRIA")
	tooltip_text = "%s • Energia: %d\n%s" % [card_data.name, card_data.energy_cost, Catalog.description(card_data)]
	set_hard_mode(hide_illustrations)

func _fit_text(label: Label, maximum: int, minimum: int) -> void:
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.clip_text = true
	var font := Style.readable()
	var lines := label.text.split("\n")
	for font_size in range(maximum, minimum - 1, -1):
		var widest := 0.0
		for line in lines:
			widest = maxf(widest, font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x)
		if widest <= label.size.x and font.get_height(font_size) * lines.size() <= label.size.y:
			label.add_theme_font_size_override("font_size", font_size)
			return
	label.add_theme_font_size_override("font_size", minimum)

func set_hard_mode(enabled: bool) -> void:
	hard_mode = enabled
	custom_minimum_size = Vector2(128, 196)
	size = custom_minimum_size
	symbol.visible = not enabled
	texture_rect.visible = not enabled
	value.position.y = 58 if enabled else 88
	value.size.y = 94 if enabled else 70
	_fit_text(value, 17, 12)
	target_label.visible = true

func set_interaction_enabled(enabled: bool) -> void:
	interaction_enabled = enabled
	if not enabled and dragging:
		dragging = false
		return_to_slot()

func set_affordable(affordable: bool) -> void:
	modulate = Color.WHITE if affordable or is_played else Color(0.65, 0.65, 0.65)

func _gui_input(event: InputEvent) -> void:
	if not interaction_enabled:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		dragging = true
		original_position = position
		drag_offset = get_global_transform().basis_xform(event.position)
		z_index = 100
		accept_event()

func _input(event: InputEvent) -> void:
	if not dragging:
		return
	if event is InputEventMouseMotion:
		global_position = get_canvas_transform().affine_inverse() * event.position - drag_offset
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		dragging = false
		z_index = 0
		check_drop(get_canvas_transform().affine_inverse() * event.position)
		get_viewport().set_input_as_handled()

func check_drop(pointer_position: Vector2) -> void:
	if not interaction_enabled or not is_instance_valid(drop_zone):
		return_to_slot()
		return
	var inside := drop_zone.get_global_rect().has_point(pointer_position)
	if inside and not is_played:
		card_played.emit(self)
	elif not inside and is_played:
		card_removed.emit(self)
	else:
		return_to_slot()

func return_to_slot() -> void:
	position = original_position
	if get_parent() is Container:
		get_parent().queue_sort()
	z_index = 0

func _on_hover() -> void:
	if interaction_enabled and not dragging:
		z_index = 10
		card_hovered.emit()

func _on_exit() -> void:
	if not dragging:
		z_index = 0
		card_exited.emit()
