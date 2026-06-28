extends Node2D

@onready var hp_label: Label = $HpLabel
@onready var shield_label: Label = $ShieldLabel

var max_health: int = 1

func setup(current: int, maximum: int) -> void:
	max_health = maximum
	update_hp(current)

func update_hp(current: int) -> void:
	hp_label.text = "❤ %d/%d" % [current, max_health]

func update_shield(amount: int) -> void:
	if amount > 0:
		shield_label.text = "🛡 %d" % amount
		shield_label.visible = true
	else:
		shield_label.visible = false
