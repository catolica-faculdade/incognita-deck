extends RefCounted
## Somente recursos originais do jogo: papel, tinta e escrita à mão.

const INK := Color("24231f")
const PAPER := Color("f5f0e5")
const NOTE = preload("res://assets/empty_paper.png")
const MENU_BACKGROUND = preload("res://assets/backgrounds/background_menu.png")
const MAP_BACKGROUND = preload("res://assets/backgrounds/background_map.png")
const DoodleButton = preload("res://interface/doodle_button.gd")
static var _handwriting: SystemFont
static var _readable: Font

static func readable() -> Font:
	if _readable == null:
		_readable = ThemeDB.fallback_font.duplicate()
		if _readable is FontFile:
			_readable.oversampling = 2.0
			_readable.hinting = TextServer.HINTING_NORMAL
			_readable.generate_mipmaps = true
	return _readable

static func handwriting() -> SystemFont:
	if _handwriting == null:
		_handwriting = SystemFont.new()
		_handwriting.font_names = PackedStringArray(["Segoe Print", "Comic Sans MS", "Chalkboard SE", "DejaVu Sans"])
		_handwriting.multichannel_signed_distance_field = true
		_handwriting.msdf_size = 64
	return _handwriting

static func label(text: String, font_size: int = 18) -> Label:
	var node := Label.new()
	node.text = text
	node.add_theme_color_override("font_color", INK)
	node.add_theme_font_override("font", handwriting() if font_size >= 24 else readable())
	node.add_theme_font_size_override("font_size", font_size)
	return node

static func readable_label(text: String, font_size: int = 18) -> Label:
	var node := label(text, font_size)
	node.add_theme_font_override("font", readable())
	return node

static func button(text: String, callback: Callable) -> Button:
	var node := DoodleButton.new()
	node.text = text
	node.custom_minimum_size = Vector2(0, 48)
	node.add_theme_font_override("font", readable())
	node.add_theme_font_size_override("font_size", 17)
	node.add_theme_stylebox_override("normal", button_paper())
	var hover := button_paper()
	hover.modulate_color = Color(1.0, 0.98, 0.87)
	node.add_theme_stylebox_override("hover", hover)
	var pressed := button_paper()
	pressed.modulate_color = Color(0.93, 0.90, 0.82)
	node.add_theme_stylebox_override("pressed", pressed)
	var disabled := button_paper()
	disabled.modulate_color = Color(1, 1, 1, 0.5)
	node.add_theme_stylebox_override("disabled", disabled)
	node.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		node.add_theme_color_override(state, INK)
	node.add_theme_color_override("font_disabled_color", Color("88857e"))
	node.pressed.connect(callback)
	return node

static func button_paper() -> StyleBoxTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = NOTE
	atlas.region = Rect2(110, 180, NOTE.get_width() - 140, 150)
	var style := StyleBoxTexture.new()
	style.texture = atlas
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

static func illustrated_button(texture: Texture2D, callback: Callable) -> Button:
	var node := button("", callback)
	node.draw_outline = false
	for state in ["normal", "hover", "pressed", "disabled"]:
		var style := StyleBoxTexture.new()
		style.texture = texture
		if state == "hover":
			style.modulate_color = Color(1.0, 0.98, 0.86)
		elif state == "disabled":
			style.modulate_color.a = 0.5
		node.add_theme_stylebox_override(state, style)
	return node

static func box(color: Color = PAPER, _border: Color = INK) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = NOTE
	style.texture_margin_left = 100
	style.texture_margin_right = 18
	style.texture_margin_top = 16
	style.texture_margin_bottom = 16
	style.content_margin_left = 110
	style.content_margin_right = 20
	style.content_margin_top = 9
	style.content_margin_bottom = 9
	style.modulate_color = Color(1, 1, 1, color.a)
	return style

static func background(root: Control, texture: Texture2D = MENU_BACKGROUND) -> TextureRect:
	var node := TextureRect.new()
	node.name = "DoodleBackground"
	node.texture = texture
	node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(node)
	node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return node

static func screen(root: Control, title: String, subtitle: String) -> VBoxContainer:
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background(root)
	var margin := MarginContainer.new()
	root.add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 100)
	margin.add_theme_constant_override("margin_right", 100)
	margin.add_theme_constant_override("margin_top", 42)
	margin.add_theme_constant_override("margin_bottom", 42)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	margin.add_child(content)
	var heading := label(title, 30)
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(heading)
	var description := label(subtitle, 16)
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(description)
	return content
