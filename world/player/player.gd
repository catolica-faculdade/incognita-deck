extends Node2D
var max_health := 80
var health := max_health
var poisoned := false
var poison_amount := 0
var shield := false
var shield_amount := 0

signal status_changed


const trajectory_scene = preload("res://world/player/trajectory.tscn")

func _ready() -> void:
	global_position = Vector2(100, 0)
	var trajectory = trajectory_scene.instantiate()
	add_child(trajectory)

func take_damage(amount):
	health -= amount
	check_is_alive()
	status_changed.emit()
	
func receive_poison(amount):
	poisoned = true
	poison_amount += amount
	status_changed.emit()
	
func on_end_turn():
	if(poisoned):
		if(poison_amount > 0):
			take_damage(poison_amount)
			poison_amount -= 1
			check_is_alive()
		else:
			poisoned = false
			poison_amount = 0

func check_is_alive():
	if(health > 0):
		return true
	else:
		get_tree().change_scene_to_file("res://main/main.tscn")


func get_player_status() -> Dictionary:
	return {
		"health": health,
		"max_health": max_health,
		"poison": poisoned,
		"poison_amount": poison_amount,
		"shield": shield,
		"shield_amount": shield_amount
	}
