extends RefCounted
## Regras de seleção do turno, independentes dos nós e do arraste da interface.

var max_energy: int
var current_energy: int
var enabled := false
var _selected: Dictionary = {}

func _init(energy: int = 5) -> void:
	max_energy = energy
	current_energy = energy

func try_play(id: int, data: Dictionary) -> bool:
	var cost := int(data.get("energy_cost", 1))
	if not enabled or _selected.has(id) or cost < 0 or cost > current_energy:
		return false
	_selected[id] = data.duplicate(true)
	current_energy -= cost
	return true

func try_remove(id: int) -> bool:
	if not enabled or not _selected.has(id):
		return false
	current_energy += int(_selected[id].get("energy_cost", 1))
	_selected.erase(id)
	return true

func clear() -> bool:
	if not enabled:
		return false
	_selected.clear()
	current_energy = max_energy
	return true

func start_round() -> void:
	_selected.clear()
	current_energy = max_energy

func cards_data() -> Array:
	return _selected.values().duplicate(true)
