extends TextureButton

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if is_in_group("start"):
		GameManager.start_run()
	elif is_in_group("leave"):
		get_tree().quit()
