extends CanvasLayer

const Style = preload("res://interface/ui_style.gd")
const CARD_SCENE = preload("res://card/card.tscn")
var choice_buttons: Array = []
var offered_cards: Array = []
var chosen := false

func _ready() -> void:
	layer = 8
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	GameManager.current_context = GameManager.Context.REWARD
	var root := Control.new()
	add_child(root)
	var boss_name: String = GameManager.current_encounter.get("boss_name", "")
	var title := "Vitória contra %s!" % boss_name if not boss_name.is_empty() else "Vitória!"
	var elite: bool = GameManager.current_encounter.get("kind", "") == "elite"
	var content := Style.screen(root, title, "Escolha 1 carta. Recompensa de Elite com rara garantida." if elite else "Escolha 1 carta.")
	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(center)
	var offers := HBoxContainer.new()
	offers.add_theme_constant_override("separation", 32)
	center.add_child(offers)
	for data in GameManager.pending_rewards:
		var column := VBoxContainer.new()
		column.custom_minimum_size = Vector2(230, 0)
		column.add_theme_constant_override("separation", 16)
		offers.add_child(column)
		var card_center := CenterContainer.new()
		column.add_child(card_center)
		var card := CARD_SCENE.instantiate()
		card_center.add_child(card)
		card.setup(data)
		offered_cards.append(card)
		var rarity := Style.readable_label("Rara" if data.get("rare", false) else "", 15)
		rarity.custom_minimum_size.y = 22
		rarity.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rarity.add_theme_color_override("font_color", Color("755325"))
		column.add_child(rarity)
		var button := Style.button("Escolher", _choose.bind(int(data.id)))
		column.add_child(button)
		choice_buttons.append(button)
	var footer := Style.label("%d cartas • HP %d/%d • %s" % [GameManager.get_run_deck().size(), GameManager.player_health, GameManager.max_player_health, "Difícil" if GameManager.hard_mode else "Normal"], 16)
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(footer)
	content.add_child(Style.button("Pular", _choose.bind(-1)))

func _choose(card_id: int) -> void:
	if chosen or not GameManager.claim_reward(card_id):
		return
	chosen = true
	get_tree().paused = false
	GameManager.continue_after_reward()
