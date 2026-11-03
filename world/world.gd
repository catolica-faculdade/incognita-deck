extends Node2D
## Compatibilidade com a antiga cena world.tscn: usa o mesmo fluxo oficial.

func _ready() -> void:
	GameManager.call_deferred("start_combat", "res://world/combat/combat_1.tscn")
