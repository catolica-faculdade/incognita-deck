extends CanvasLayer

const Style = preload("res://interface/ui_style.gd")
const Catalog = preload("res://card/card_database.gd")
const CARD_SCENE = preload("res://card/card.tscn")
var _was_paused := false
var card_views: Array = []

func _ready() -> void:
	layer = 12
	process_mode = Node.PROCESS_MODE_ALWAYS
	_was_paused = get_tree().paused
	get_tree().paused = true
	var root := Control.new()
	add_child(root)
	var content := Style.screen(root, "Baralho desta run", "%d cartas • %s" % [GameManager.get_run_deck().size(), "Modo difícil" if GameManager.hard_mode else "Modo normal"])
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(scroll)
	var grid := HFlowContainer.new()
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 16)
	scroll.add_child(grid)
	for id in GameManager.get_run_deck():
		var card := CARD_SCENE.instantiate()
		grid.add_child(card)
		card.setup(Catalog.get_card(id))
		card_views.append(card)
	content.add_child(Style.button("Fechar baralho", _close))

func _close() -> void:
	get_tree().paused = _was_paused
	queue_free()
