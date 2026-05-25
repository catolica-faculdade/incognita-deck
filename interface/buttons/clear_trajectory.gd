extends TextureButton

signal clear_trajectory

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	print("Limpando trajetória!")
	clear_trajectory.emit()
