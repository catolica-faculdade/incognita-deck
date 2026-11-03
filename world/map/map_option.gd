extends TextureButton

@export var level := 0
var _chosen := false

func _ready() -> void:
	pressed.connect(_on_pressed)
	GameManager.current_context = GameManager.Context.MAP
	disabled = level != GameManager.level
	modulate.a = 0.5 if disabled else 1.0

func _on_pressed() -> void:
	if disabled or _chosen:
		return
	_chosen = true
	if is_in_group("combat"):
		GameManager.start_combat(_random_combat())
	elif is_in_group("boss"):
		GameManager.start_combat("res://world/combat/combat_boss.tscn")
	elif is_in_group("question_mark") or is_in_group("question"):
		var event := randi_range(1, 100)
		if event <= 40:
			GameManager.start_combat(_random_combat())
		elif event <= 80:
			GameManager.complete_rest()
		else:
			# O protótipo não possui recompensa: evento vazio avança sem inventar conteúdo.
			GameManager.level += 1
			GameManager.return_to_map()
	elif is_in_group("rest"):
		GameManager.complete_rest()
	elif is_in_group("test"):
		GameManager.start_combat("res://world/combat/test_%d.tscn" % randi_range(1, 3))
	else:
		_chosen = false

func _random_combat() -> String:
	return "res://world/combat/combat_%d.tscn" % randi_range(1, 5)
