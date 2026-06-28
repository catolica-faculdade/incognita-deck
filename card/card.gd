extends Control

@export var scale_hover: Vector2 = Vector2(1.1, 1.1)
@export var scale_default: Vector2 = Vector2(1.0, 1.0)
@export var animation_duration: float = 0.15

@onready var texture_rect = $TextureRect
@onready var button = $Button

var card_data: Dictionary = {}
var default_texture = preload("res://assets/cards/general/card_default.jpeg")
var tween: Tween

var dragging := false
var drag_offset := Vector2()

var original_position: Vector2
var original_parent

var is_played := false

signal card_played(card)
signal card_removed(card)

signal card_hovered
signal card_exited

@onready var title = $Title
@onready var symbol: TextureRect = $Symbol
@onready var value = $Value

const SYMBOLS = {
	"linear": {
		"texture": preload("res://assets/cards/general/symbol_forward.png"),
		"position": Vector2(10, 65),
		"size": Vector2(20, 30)
	},
	"diagonal": {
		"texture": preload("res://assets/cards/general/symbol_up.png"),
		"position": Vector2(20, 65),
		"size": Vector2(20, 30)
	},
	"quadratic": {
		"texture": preload("res://assets/cards/general/symbol_arc.png"),
		"position": Vector2(20, 65),
		"size": Vector2(40, 40)
	},
	"special": {
		"texture": preload("res://assets/cards/general/symbol_wave.png"),
		"position": Vector2(-10, 70),
		"size": Vector2(50, 25)
	}
}


func setup(data: Dictionary):
	card_data = data
	
	build_card()


	custom_minimum_size = Vector2(100, 200)
	size = Vector2(100, 200)

	original_parent = get_parent()
	original_position = position
	
	texture_rect.texture = card_data.get("texture", default_texture)
	texture_rect.position = Vector2.ZERO
	texture_rect.custom_minimum_size = Vector2(100, 200)
	texture_rect.size = Vector2(100, 200)
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	button.position = Vector2.ZERO
	button.custom_minimum_size = Vector2(100, 200)
	button.size = Vector2(100, 200)

	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
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

	if not drop_zone:
		return_to_hand()
		return

	var is_inside_dropzone = drop_zone.get_global_rect().has_point(get_global_mouse_position())

	if is_inside_dropzone:

		if not is_played:
			is_played = true
			card_played.emit(self)

	else:

		if is_played:
			is_played = false
			card_removed.emit(self)
		else:
			return_to_hand()


func return_to_hand():

	if not original_parent:
		return

	if get_parent():
		get_parent().remove_child(self)

	original_parent.add_child(self)

	position = original_position


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
	tween.tween_property(self, "scale", target_scale, animation_duration) \
		.set_trans(Tween.TRANS_QUAD) \
		.set_ease(Tween.EASE_OUT)


func build_card():

	title.text = card_data.name

	match card_data.type:

		"linear":
			build_linear()
			
		"diagonal":
			build_diagonal()

		"quadratic":
			build_quadratic()

		"special":
			build_special()
			
			
			
func build_linear():

	setup_symbol(card_data.type)

	var x = card_data.x
	var y = card_data.y

	if y == 0:
		value.text = "x + %d" % int(x)

	elif x == 0:
		value.text = "y + %d" % int(y)

	else:
		value.text = "(%d, %d)" % [int(x), int(y)]
		
func build_diagonal():

	setup_symbol(card_data.type)

	var x = card_data.x
	var y = card_data.y

	if y == 0:
		value.text = "x + %d" % int(x)

	elif x == 0:
		value.text = "y + %d" % int(y)

	else:
		value.text = "(%d, %d)" % [int(x), int(y)]
		

func build_quadratic():

	setup_symbol(card_data.type)

	var a = card_data.value

	if a > 0:
		value.text = "a = %.2f" % a
	else:
		value.text = "a = %.2f" % a
		
func build_special():
	match card_data.special_type:
		"wave":
			setup_symbol(card_data.type)

			value.text = "A %.1f\nF %.1f" % [
				card_data.amplitude,
				card_data.frequency
			]


func setup_symbol(type: String):
	var info = SYMBOLS[type]

	symbol.texture = info.texture
	symbol.position = info.position
	symbol.custom_minimum_size = info.size
	symbol.size = info.size
