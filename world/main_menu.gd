extends TextureButton

func _ready():
	pressed.connect(_on_pressed)
	GameManager.current_context = GameManager.Context.MAIN_MENU

func _on_pressed():
	if is_in_group("start"):
		get_tree().change_scene_to_file("res://world/map_1.tscn")
	if is_in_group("leave"):
		get_tree().quit()
