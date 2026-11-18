extends CanvasLayer
## Aula prática isolada: não grava nem substitui o save até começar a campanha.

const Style = preload("res://interface/ui_style.gd")
const Catalog = preload("res://card/card_database.gd")
const LESSONS := {
	"welcome": ["Bem-vindo ao treino", "Sou o Monitor! Vamos praticar uma batalha juntos. Você aprenderá a ler cartas, mirar, se proteger e planejar o próximo turno. Este treino não altera sua partida salva.", "Conhecer o mapa"],
	"deck": ["Conheça seu baralho", "O mapa liga os encontros da campanha. Antes de escolher um caminho, clique em Ver baralho, no alto à direita, ou pressione Tab. O baralho completo é diferente da mão comprada em cada turno.", ""],
	"deck_read": ["Suas ferramentas", "Aqui estão todas as cartas do treino. Elevar desenha uma diagonal; Guarda dá escudo; Giz afiado aumenta o dano; Tinta tóxica aplica veneno; Remendo cura. Passe o mouse nas cartas para ler os detalhes. Depois feche com Tab ou Fechar baralho.", ""],
	"path": ["Escolha seu caminho", "Clique em um dos nós disponíveis na primeira coluna. Só caminhos conectados ficam acessíveis. Combates dão cartas; elites garantem uma opção rara; descanso cura ou remove uma carta; eventos oferecem escolhas. Neste treino, qualquer caminho inicial leva à mesma aula.", ""],
	"combat": ["Sua primeira batalha", "Você tem 80 de vida e 5 energias por turno. As cartas ficam embaixo; o custo aparece no círculo amarelo. Vencer exige derrotar todos os inimigos. Vamos primeiro descobrir o que este adversário pretende fazer.", "Analisar o inimigo"],
	"enemy": ["Observe antes de agir", "Mantenha o mouse sobre o inimigo ou sua barra de vida. Leia o nome, a vida, o escudo e a próxima ação. A intenção ajuda a decidir entre atacar e se proteger. Aguarde a dica aparecer.", "Li a intenção"],
	"card": ["Leia a carta Elevar", "Passe o mouse sobre Elevar na mão. Ela custa 1 energia e desloca o final da trajetória 5 unidades para a direita e 2 para cima. A fórmula descreve o movimento; o custo informa quanto você pode combinar neste turno.", "Entendi a carta"],
	"play": ["Prepare Elevar", "Arraste Elevar para a área acima da mão ou pressione o número indicado nela. Preparar uma carta gasta energia, mas ainda não dispara. Você pode experimentar antes de confirmar.", ""],
	"preview": ["Confira a trajetória", "A linha mostra por onde o projétil vai passar. O losango junto à vida do inimigo indica que ele será atingido. Neste treino, Elevar já alcança o alvo. Em outros encontros, combine deslocamentos, parábolas e ondas para ajustar a mira.", "Adicionar proteção"],
	"guard": ["Combine um efeito", "Prepare Guarda. Ela custa 1 energia e concede 7 de escudo ao confirmar o turno. O escudo absorve dano e expira no início do seu próximo turno. Ao contrário do veneno e do dano extra, a proteção não depende de acertar um inimigo.", ""],
	"clear": ["Experimente sem perder energia", "Agora clique em Limpar, no canto inferior esquerdo. As cartas voltam para a mão e a energia é devolvida. Você também pode devolver uma carta preparada pela tecla dela. Experimente antes de confirmar a jogada.", ""],
	"rebuild": ["Monte sua combinação", "Prepare Elevar e Guarda novamente, em qualquer ordem. A trajetória deve alcançar o inimigo e o painel de efeitos deve indicar o escudo. Vamos guardar as outras cartas para explicar o fim do turno.", ""],
	"end": ["Encerre a preparação", "Clique em Fim do turno ou pressione E / Espaço. Primeiro você escolherá o que manter na mão. Ainda não é o disparo: existe uma confirmação para revisar essa escolha.", ""],
	"keep": ["Guarde uma carta", "Clique em Remendo para mantê-la no próximo turno. Manter cartas custa zero energia. Você pode guardar até duas; cartas jogadas e as demais vão para o descarte. Um espaço verde confirma a seleção.", ""],
	"confirm": ["Agora confirme", "Clique em Continuar ou pressione E / Espaço. Observe o projétil atingir o inimigo e o escudo proteger você na resposta. Em combates normais, os inimigos sobreviventes agem depois do seu disparo.", ""],
	"wait": ["Observe a resolução", "O disparo aplica o ataque, depois o inimigo responde. Espere as animações. A energia será restaurada e você comprará até cinco cartas, além das que manteve.", ""],
	"round": ["Um novo turno", "Remendo ficou na mão e você recebeu novas cartas: a mão pode chegar a sete. O escudo anterior expirou e a energia voltou a 5. Quando a compra acaba, o descarte é embaralhado. Cura respeita a vida máxima; veneno ignora escudo e perde uma carga por ativação.", "Terminar a batalha"],
	"practice": ["Sua vez de decidir", "Derrote o inimigo! Elevar alcança o alvo; Giz afiado acrescenta 8 de dano e Tinta tóxica aplica veneno se o disparo acertar. Remendo cura 5 de vida e Guarda protege. Confira a intenção, prepare sua combinação e finalize o turno. Você pode abrir o baralho com Tab.", ""],
	"reward": ["Construa seu baralho", "Vitória! Escolha uma das três cartas para acrescentar ao baralho, ou use Pular. A escolha acompanha você durante a campanha. Nas elites, pelo menos uma opção é rara. Esta recompensa pertence só ao treino.", ""],
	"finish": ["Você está pronto!", "Os próximos caminhos estão liberados no mapa. Na campanha, preserve sua vida, melhore seu baralho e vença os três chefes e o ENEM. Esc abre a pausa e Salvar run. Continuar run retoma o ponto salvo; combates reiniciam no turno 1. Vamos começar uma campanha nova na dificuldade escolhida?", "Começar campanha"]
}

var active := false
var step := ""
var difficult := false
var panel: PanelContainer
var heading: Label
var speech: Label
var next_button: Button
var hover_time := 0.0
var hover_done := false
var highlight: ReferenceRect
var skip_dialog: ConfirmationDialog

func _ready() -> void:
	layer = 18
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel = PanelContainer.new()
	panel.custom_minimum_size.x = 280
	var paper := StyleBoxFlat.new()
	paper.bg_color = Color("fff9e8")
	paper.border_color = Color("977744")
	paper.set_border_width_all(2)
	paper.set_corner_radius_all(10)
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		paper.set_content_margin(side, 12)
	panel.add_theme_stylebox_override("panel", paper)
	add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 9)
	panel.add_child(column)
	heading = Style.readable_label("", 18)
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(heading)
	speech = Style.readable_label("", 15)
	speech.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(speech)
	next_button = Style.button("", advance)
	column.add_child(next_button)
	var skip := Style.button("Sair do tutorial", func(): skip_dialog.popup_centered())
	skip.custom_minimum_size.y = 34
	skip.add_theme_font_size_override("font_size", 14)
	column.add_child(skip)
	highlight = ReferenceRect.new()
	highlight.editor_only = false
	highlight.border_color = Color("d49c20")
	highlight.border_width = 3.0
	highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(highlight)
	skip_dialog = ConfirmationDialog.new()
	skip_dialog.title = "Sair do tutorial?"
	skip_dialog.dialog_text = "Começar uma campanha nova agora?\nIsso substituirá a partida salva anterior."
	skip_dialog.confirmed.connect(finish)
	add_child(skip_dialog)
	cancel()

func start(hard: bool) -> void:
	if GameManager._changing_scene:
		return
	GameManager.prepare_run(hard, 18011)
	difficult = hard
	active = true
	GameManager.run_deck = [2, 17, 19, 18, 16, 2, 17, 19, 18, 16, 2, 17]
	set_step("welcome")
	GameManager.return_to_map()

func cancel() -> void:
	active = false
	step = ""
	if is_instance_valid(panel):
		panel.hide()
		highlight.hide()
		skip_dialog.hide()

func finish() -> void:
	if GameManager._changing_scene:
		return
	var mode := difficult
	cancel()
	GameManager.begin_run(mode)

func set_step(value: String) -> void:
	step = value
	hover_time = 0.0
	hover_done = false
	var lesson: Array = LESSONS[step]
	heading.text = "Monitor • " + str(lesson[0])
	speech.text = str(lesson[1])
	next_button.text = str(lesson[2])
	next_button.visible = not next_button.text.is_empty()
	next_button.disabled = step in ["enemy", "card"]
	panel.show()
	panel.size = Vector2(280, 0)

func advance() -> void:
	if not active or (step in ["enemy", "card"] and not hover_done):
		return
	var transitions := {"welcome":"deck", "combat":"enemy", "enemy":"card", "card":"play", "preview":"guard", "round":"practice"}
	if step == "finish":
		finish()
	elif transitions.has(step):
		set_step(transitions[step])

func allows(action: String, card_id: int = -1) -> bool:
	if not active:
		return true
	match action:
		"map": return step == "path"
		"deck": return step in ["deck", "practice"]
		"play": return step == "practice" or (step == "play" and card_id == 2) or (step == "guard" and card_id == 17) or (step == "rebuild" and card_id in [2, 17])
		"remove": return step in ["rebuild", "practice"]
		"clear": return step in ["clear", "rebuild", "practice"]
		"end": return step in ["end", "practice"]
		"retain": return step == "practice" or (step == "keep" and card_id == 16)
		"confirm": return step in ["confirm", "practice"]
		"reward": return step == "reward"
	return true

func event(action: String) -> void:
	if not active:
		return
	var transitions := {"deck:opened":"deck_read", "deck_read:closed":"path", "path:selected":"combat", "play:played":"preview", "guard:played":"clear", "clear:cleared":"rebuild", "end:ending":"keep", "keep:retained":"confirm", "confirm:confirmed":"wait", "reward:claimed":"finish"}
	var key := step + ":" + action
	if transitions.has(key):
		set_step(transitions[key])

func encounter() -> Dictionary:
	return {"seed":18011, "tier":1, "world":0, "boss":false, "kind":"combat", "enemies":[{"archetype":"pencil", "position":Vector2(335, -390), "tier":1, "seed":1}]}

func prepare_battle(battle: Node) -> void:
	if not active:
		return
	for enemy in battle.scenario_container.get_children():
		if enemy.is_in_group("enemies"):
			enemy.max_health = 25
			enemy.health = 25
			enemy.base_damage = 3
			enemy.planned_action = "attack"
			enemy.hud.setup(25, 25)
			enemy._refresh_hud()

func _process(delta: float) -> void:
	if not active:
		return
	var scene := get_tree().current_scene
	if not is_instance_valid(scene):
		return
	var size := get_viewport().get_visible_rect().size
	var combat := GameManager.current_context == GameManager.Context.COMBAT
	panel.position = Vector2(12 if combat else size.x - 300, 138)
	panel.size.x = 280
	panel.size.y = panel.get_combined_minimum_size().y
	highlight.hide()
	if get_tree().paused and GameManager.current_context != GameManager.Context.REWARD:
		panel.visible = step == "deck_read"
		return
	panel.show()
	if not combat or not "combat_ui" in scene:
		if step == "deck" and "deck_button" in scene:
			mark(scene.deck_button)
		elif step == "path" and "node_buttons" in scene:
			mark(scene.node_buttons[GameManager.available_nodes[0]])
		return
	var ui = scene.combat_ui
	if step == "wait" and ui.turn_count >= 2 and ui.selection.enabled:
		set_step("round")
	if step == "rebuild" and ui.selection.cards_data().size() == 2:
		set_step("end")
	var target: Control
	if step == "enemy":
		for enemy in scene.scenario_container.get_children():
			if enemy.is_in_group("enemies"):
				target = enemy.hud.body_hover
				var hovering: bool = enemy.hud.hover_info.visible
				hover_time = hover_time + delta if hovering else 0.0
	elif step in ["card", "play", "guard", "keep"]:
		var id: int = 17 if step == "guard" else (16 if step == "keep" else 2)
		for card in ui.card_container.get_children():
			if int(card.card_data.id) == id:
				target = card
				if step == "card":
					var hovered := get_viewport().gui_get_hovered_control()
					hover_time = hover_time + delta if hovered == card or (hovered != null and card.is_ancestor_of(hovered)) else 0.0
				break
	elif step == "clear": target = ui.clear_button
	elif step == "end": target = ui.end_turn_button
	elif step == "confirm": target = ui.confirm_keep_button
	if is_instance_valid(target):
		mark(target)
	if hover_time >= 1.0:
		hover_done = true
		next_button.disabled = false

func mark(control: Control) -> void:
	var transform := control.get_global_transform_with_canvas()
	highlight.position = transform * Vector2.ZERO - Vector2(4, 4)
	highlight.size = control.size * transform.get_scale() + Vector2(8, 8)
	highlight.show()
