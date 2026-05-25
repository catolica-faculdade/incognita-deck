extends Control

@export var scale_hover: Vector2 = Vector2(1.1, 1.1)
@export var scale_default: Vector2 = Vector2(1.0, 1.0)
@export var animation_duration: float = 0.15

@onready var texture_rect = $TextureRect
@onready var button = $Button

var card_data: Dictionary = {}
var default_texture = preload("res://assets/placeholder.jpg")
var tween: Tween

signal card_pressed(card_data: Dictionary)

func setup(data: Dictionary):
	card_data = data
	custom_minimum_size = Vector2(100, 200)
	size = Vector2(100, 200)

	texture_rect.texture = card_data.get("texture", default_texture)

	button.pressed.connect(_on_pressed)

func _on_pressed():
	card_pressed.emit(card_data)

func _on_hover():
	z_index = 10
	_animate_scale(scale_hover)

func _on_exit():
	z_index = 0
	_animate_scale(scale_default)

func _animate_scale(target_scale: Vector2) -> void:
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	
	tween.tween_property(self, "scale", target_scale, animation_duration)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
