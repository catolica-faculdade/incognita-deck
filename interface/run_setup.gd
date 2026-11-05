extends Control

const Style = preload("res://interface/ui_style.gd")
var normal_button: Button
var hard_button: Button

func _ready() -> void:
	GameManager.current_context = GameManager.Context.SETUP
	var content := Style.screen(self, "Antes de começar", "Escolha como quer estudar nesta run.")
	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(680, 0)
	panel.add_theme_stylebox_override("panel", Style.box(Color("fffdf5")))
	center.add_child(panel)
	var choices := VBoxContainer.new()
	choices.add_theme_constant_override("separation", 18)
	panel.add_child(choices)
	choices.add_child(Style.label("As mesmas contas. Um desafio diferente.", 24))
	choices.add_child(Style.label("Normal: ilustrações, fórmulas e custos nas cartas."))
	choices.add_child(Style.label("Difícil: apenas texto e contas; sem ilustrações nas cartas."))
	choices.add_child(Style.label("Cada run tem um mapa novo. As recompensas formam seu baralho.", 16))
	normal_button = Style.button("Começar no modo normal", func(): GameManager.begin_run(false))
	hard_button = Style.button("Começar no modo difícil", func(): GameManager.begin_run(true))
	choices.add_child(normal_button)
	choices.add_child(hard_button)
	content.add_child(Style.button("Voltar ao menu", GameManager.return_to_menu))
