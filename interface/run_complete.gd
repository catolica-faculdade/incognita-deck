extends Control

const Style = preload("res://interface/ui_style.gd")

func _ready() -> void:
	GameManager.current_context = GameManager.Context.FINISHED
	var content := Style.screen(self, "Run concluída!", "Você venceu o Professor e completou o caminho.")
	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(center)
	center.add_child(Style.label("%d vitórias\n%d cartas no baralho\n%s\nSemente: %d" % [GameManager.victories, GameManager.get_run_deck().size(), "Modo difícil" if GameManager.hard_mode else "Modo normal", GameManager.run_seed], 28))
	content.add_child(Style.button("Nova run — escolher modo", GameManager.start_run))
	content.add_child(Style.button("Menu principal", GameManager.return_to_menu))
