extends CanvasLayer

@onready var button: Button = $ColorRect/VBoxContainer/Button

func _ready():
	get_tree().paused = true
	button.pressed.connect(_on_continue)
	var tween := create_tween()
	tween.tween_property($ColorRect, "modulate:a", 1.0, 0.8)\
		.from(0.0).set_trans(Tween.TRANS_QUAD)

func _on_continue():
	get_tree().paused = false
	GameManager.level = -1
	GameManager.end_game()
