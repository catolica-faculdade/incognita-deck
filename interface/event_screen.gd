extends Control

const Style = preload("res://interface/ui_style.gd")

var answers: VBoxContainer
var feedback: Label
var answer := 0

func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(GameManager.current_node.get("seed", 0))
	var slope := rng.randi_range(2, 5)
	var intercept := rng.randi_range(1, 7)
	var x := rng.randi_range(2, 7)
	answer = slope * x + intercept
	var content := Style.screen(self, "Desafio do Monitor", "Acerte a questão para escolher uma carta.")
	var options := VBoxContainer.new()
	options.custom_minimum_size.x = 410
	options.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	options.add_theme_constant_override("separation", 8)
	content.add_child(options)
	answers = VBoxContainer.new()
	answers.add_theme_constant_override("separation", 8)
	options.add_child(answers)
	answers.add_child(Style.readable_label("Se y = %dx + %d, quanto vale y para x = %d?" % [slope, intercept, x], 18))
	var values := [answer - slope, answer, answer + intercept]
	var rotation := rng.randi_range(0, values.size() - 1)
	for i in range(values.size()):
		var value: int = values[(i + rotation) % values.size()]
		answers.add_child(Style.button(str(value), _answer.bind(value)))
	feedback = Style.readable_label("", 16)
	options.add_child(feedback)
	feedback.hide()
	options.add_child(Style.button("Treinar em combate", _choose.bind("combat")))
	options.add_child(Style.button("Seguir viagem", _choose.bind("skip")))

func _answer(value: int) -> void:
	if not answers.visible:
		return
	if value == answer:
		_choose("quiz")
	else:
		answers.hide()
		feedback.text = "O resultado era %d. Você pode treinar ou seguir." % answer
		feedback.show()

func _choose(choice: String) -> void:
	GameManager.resolve_event(choice)
