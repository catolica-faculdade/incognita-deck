extends Control

const Style = preload("res://interface/ui_style.gd")
var start_button: TextureButton
var leave_button: TextureButton
var logo: TextureRect
var settings_button: TextureButton
var composition: VBoxContainer

func _ready() -> void:
	GameManager.current_context = GameManager.Context.MAIN_MENU
	Style.background(self)
	composition = VBoxContainer.new()
	composition.name = "MenuComposition"
	composition.add_theme_constant_override("separation", 24)
	add_child(composition)
	logo = TextureRect.new()
	var title_art := AtlasTexture.new()
	title_art.atlas = preload("res://assets/texts/title_incognita_deck.png")
	# O PNG original tem margens transparentes grandes fora da escrita.
	title_art.region = Rect2(165, 350, 1240, 250)
	logo.texture = title_art
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.custom_minimum_size = Vector2(600, 150)
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	composition.add_child(logo)
	var start_center := CenterContainer.new()
	composition.add_child(start_center)
	start_button = _art_button(preload("res://assets/buttons/button_start_menu.png"), preload("res://assets/buttons/button_start_hover_menu.png"), Vector2(480, 164))
	start_button.name = "StartButton"
	start_button.pressed.connect(GameManager.start_run)
	start_center.add_child(start_button)
	var leave_center := CenterContainer.new()
	composition.add_child(leave_center)
	leave_button = _art_button(preload("res://assets/buttons/button_leave_menu.png"), preload("res://assets/buttons/button_leave_hover_menu.png"), Vector2(360, 130))
	leave_button.name = "LeaveButton"
	leave_button.pressed.connect(func(): get_tree().quit())
	leave_center.add_child(leave_button)
	var settings_art := AtlasTexture.new()
	settings_art.atlas = preload("res://assets/buttons/config_icon.png")
	settings_art.region = Rect2(245, 250, 770, 780)
	settings_button = _art_button(settings_art, null, Vector2(66, 66))
	settings_button.tooltip_text = "Configurações"
	settings_button.pressed.connect(_on_config_pressed)
	add_child(settings_button)
	resized.connect(_layout)
	_layout()

func _art_button(normal: Texture2D, hover: Texture2D, dimensions: Vector2) -> TextureButton:
	var node := TextureButton.new()
	node.texture_normal = normal
	node.texture_hover = hover
	node.ignore_texture_size = true
	node.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	node.custom_minimum_size = dimensions
	return node

func _layout() -> void:
	var dimensions := get_viewport_rect().size
	composition.size = Vector2(600, 520)
	composition.position = Vector2((dimensions.x - 600) * 0.5, (dimensions.y - 520) * 0.5 - 12)
	settings_button.position = Vector2(dimensions.x - 112, dimensions.y - 110)
	settings_button.size = Vector2(66, 66)

func _on_config_pressed() -> void:
	PauseMenu.pause()
