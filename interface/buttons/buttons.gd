extends TextureButton

signal end_turn

func _ready() -> void:
	pressed.connect(_end_turn_button_pressed)

func _end_turn_button_pressed() -> void:
	print("Botão clicado! Emitindo sinal de fim de turno...")
	end_turn.emit()
