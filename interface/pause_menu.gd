extends CanvasLayer

var music_bus := -1
var sfx_bus := -1

var overlay: ColorRect
var music_slider: HSlider
var sfx_slider: HSlider
var button_continue: Button
var button_quit: Button

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

	var scene = load("res://interface/pause_menu.tscn").instantiate()
	add_child(scene)

	overlay = scene.get_node("ColorRect")
	music_slider = scene.get_node("ColorRect/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/HSlider")
	sfx_slider = scene.get_node("ColorRect/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/HSlider")
	button_continue = scene.get_node("ColorRect/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Button")
	button_quit = scene.get_node("ColorRect/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Button2")

	overlay.visible = false

	music_bus = AudioServer.get_bus_index("Music")
	sfx_bus = AudioServer.get_bus_index("SFX")

	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus))

	music_slider.value_changed.connect(_on_music_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	button_continue.pressed.connect(_on_continue_pressed)
	button_quit.pressed.connect(_on_quit_pressed)

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if overlay.visible:
			resume()
		else:
			pause()

func pause():
	match GameManager.current_context:
		GameManager.Context.MAIN_MENU:
			button_continue.visible = false
			button_quit.visible = false
		GameManager.Context.MAP:
			button_continue.visible = false
			button_quit.visible = true
		GameManager.Context.COMBAT:
			button_continue.visible = true
			button_quit.visible = true

	overlay.visible = true
	get_tree().paused = true

func resume():
	overlay.visible = false
	get_tree().paused = false

func _on_music_slider_changed(value: float):
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))

func _on_sfx_slider_changed(value: float):
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value))

func _on_continue_pressed():
	resume()

func _on_quit_pressed():
	overlay.visible = false
	get_tree().paused = false
	GameManager.level = 0
	GameManager.player_health = GameManager.max_player_health
	call_deferred("_change_to_main")

func _change_to_main():
	get_tree().change_scene_to_file("res://main/main.tscn")
