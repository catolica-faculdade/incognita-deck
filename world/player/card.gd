extends Control

@export var scale_hover: Vector2 = Vector2(1.1, 1.1)
@export var scale_default: Vector2 = Vector2(1.0, 1.0)
@export var animation_duration: float = 0.15

@onready var texture_rect = $TextureRect
@onready var button = $Button

var card_data: Dictionary = {}
var default_texture = preload("res://assets/placeholder.jpg")
var tween: Tween
var is_hovered := false

signal card_pressed(card_data: Dictionary)
signal card_hovered
signal card_exited

func setup(data: Dictionary):
	card_data = data
	custom_minimum_size = Vector2(100, 200)
	size = Vector2(100, 200)
	texture_rect.texture = card_data.get("texture", default_texture)
	button.pressed.connect(_on_pressed)

func _process(_delta):
	var mouse_pos = get_global_mouse_position()
	var rect = get_global_rect()
	var hovering = rect.has_point(mouse_pos)

	if hovering and not is_hovered:
		is_hovered = true
		_on_hover()
	elif not hovering and is_hovered:
		is_hovered = false
		_on_exit()

func _on_pressed():
	card_pressed.emit(card_data)

func _on_hover():
	z_index = 10
	_animate_scale(scale_hover)
	card_hovered.emit()

func _on_exit():
	z_index = 0
	_animate_scale(scale_default)
	card_exited.emit()

func _animate_scale(target_scale: Vector2) -> void:
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "scale", target_scale, animation_duration)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
