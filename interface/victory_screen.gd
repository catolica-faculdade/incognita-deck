extends CanvasLayer

@onready var title_label: Label = $ColorRect/VBoxContainer/TitleLabel
@onready var subtitle_label: Label = $ColorRect/VBoxContainer/SubtitleLabel
@onready var button: Button = $ColorRect/VBoxContainer/Button

var is_boss := false

func setup(boss: bool) -> void:
	is_boss = boss

func _ready():
	if is_boss:
		title_label.text = "VOCÊ VENCEU!"
		title_label.modulate = Color(1.0, 0.85, 0.0)
		subtitle_label.text = "O Professor foi derrotado!\nParabéns pela vitória!"
	else:
		title_label.text = "VITÓRIA!"
		title_label.modulate = Color(0.2, 0.9, 0.2)
		subtitle_label.text = "Fase concluída!\nContinue sua jornada."
	get_tree().paused = true
	button.pressed.connect(_on_continue)
	var tween := create_tween()
	tween.tween_property($ColorRect, "modulate:a", 1.0, 0.8)\
		.from(0.0).set_trans(Tween.TRANS_QUAD)

func _on_continue():
	get_tree().paused = false
	GameManager.end_game()
