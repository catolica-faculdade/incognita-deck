extends CharacterBody2D

@onready var trajectory = $Camera

func _ready() -> void:
	global_position = Vector2(100, 0)
	pass
