extends Control

@export var scale_hover: Vector2 = Vector2(1.1, 1.1)
@export var scale_default: Vector2 = Vector2(1.0, 1.0)
@export var animation_duration: float = 0.15

@onready var texture_rect = $TextureRect
@onready var button = $Button

var card_data: Dictionary = {}
var default_texture = preload("res://assets/placeholder.jpg")
var tween: Tween

var dragging := false
var drag_offset := Vector2()

var original_position: Vector2
var original_parent

signal card_played(card)


func setup(data: Dictionary):

	card_data = data

	custom_minimum_size = Vector2(100,200)
	size = Vector2(100,200)

	original_parent = get_parent()
	original_position = position
	
	texture_rect.texture = card_data.get("texture", default_texture)

	button.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _gui_input(event):
	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT:

			if event.pressed:

				dragging = true
				drag_offset = get_global_mouse_position() - global_position
				z_index = 100

			else:

				dragging = false
				z_index = 0
				check_drop()


	elif event is InputEventMouseMotion and dragging:

		global_position = get_global_mouse_position() - drag_offset


func check_drop():

	var drop_zone = get_tree().get_first_node_in_group("drop_zone")

	if drop_zone:

		if drop_zone.get_global_rect().has_point(get_global_mouse_position()):

			card_played.emit(self)

		else:

			return_to_hand()


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
		
func return_to_hand():
	get_parent().remove_child(self)

	original_parent.add_child(self)

	position = original_position
