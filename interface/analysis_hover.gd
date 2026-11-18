extends RefCounted
## Conteúdo compartilhado dos hovers; o Godot posiciona o popup dentro da janela.

const Style = preload("res://interface/ui_style.gd")

class Surface extends Control:
	func _make_custom_tooltip(for_text: String) -> Object:
		return preload("res://interface/analysis_hover.gd").make_panel(for_text)

class HealthBar extends ProgressBar:
	func _make_custom_tooltip(for_text: String) -> Object:
		return preload("res://interface/analysis_hover.gd").make_panel(for_text)

static func make_panel(text: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.custom_minimum_size.x = 390
	var paper := StyleBoxFlat.new()
	paper.bg_color = Color("fffdf5")
	paper.border_color = Color("66563b")
	paper.set_border_width_all(2)
	paper.set_corner_radius_all(8)
	paper.shadow_color = Color(0, 0, 0, 0.25)
	paper.shadow_size = 5
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		paper.set_content_margin(side, 16)
	panel.add_theme_stylebox_override("panel", paper)
	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_theme_constant_override("separation", 10)
	panel.add_child(column)
	var split := text.find("\n")
	var title := Style.readable_label(text if split < 0 else text.left(split), 22)
	title.custom_minimum_size.x = 358
	title.size.x = 358
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(title)
	if split >= 0:
		var separator := HSeparator.new()
		separator.mouse_filter = Control.MOUSE_FILTER_IGNORE
		column.add_child(separator)
		var description := Style.readable_label(text.substr(split + 1), 18)
		description.custom_minimum_size.x = 358
		description.size.x = 358
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		description.add_theme_constant_override("line_spacing", 5)
		description.mouse_filter = Control.MOUSE_FILTER_IGNORE
		column.add_child(description)
	return panel
