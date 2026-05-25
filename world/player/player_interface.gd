extends Node

@onready var health_label = $Control/Panel/HBoxContainer/HHeathContainer/HealthLabel
@onready var poison_label = $Control/Panel/HBoxContainer/HPoisonContainer/PoisonLabel
@onready var shield_label = $Control/Panel/HBoxContainer/HShieldContainer/ShieldLabel

func update_player_info(health: int, max_health: int, poison: int = 0, shield: int = 0):
	health_label.text = "HP: %d/%d" % [health, max_health]
	poison_label.text = "Veneno: %d" % poison
	shield_label.text = "Escudo: %d" % shield
