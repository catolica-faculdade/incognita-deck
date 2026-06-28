extends Node2D

@onready var label: Label = $Label

func setup(amount: int, color: Color) -> void:
	label.text = "-%d" % amount
	label.modulate = color
	
	var tween := create_tween()
	tween.tween_property(self, "position:y", position.y - 80, 0.8)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.8)\
		.set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(queue_free)
